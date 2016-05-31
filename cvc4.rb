class Cvc4 < Formula
  desc "Open-source automatic theorem prover for SMT "
  homepage "https://cvc4.cs.nyu.edu/"
  url "https://cvc4.cs.nyu.edu/builds/src/cvc4-1.5pre-smtcomp2016.tar.gz"
  version "1.5pre-smtcomp2016"
  sha256 "ee0bb9a9393ced0dd9ed657faacaf717c18a9f7e9206cc33530827e6e8059f97"

  bottle do
    cellar :any
    sha256 "45e90f3952ba323a73d0377947de1377ab421941284a10bf1989650a8f8f0e6b" => :el_capitan
    sha256 "0fcfa3a3dcad9ecd8fa457f6568458cba0f4eb020bf541515edbc8ea525a1b0f" => :yosemite
    sha256 "784e380d0c9753764618fd81144e29f8c26f2436ac4468ae822eff70d412558d" => :mavericks
  end

  head do
    url "http://cvc4.cs.nyu.edu/builds/src/unstable/latest-unstable.tar.gz"
  end

  depends_on "boost" => :build
  depends_on "gmp"
  depends_on "libantlr3c"
  depends_on :arch => :x86_64

  def install
    args = ["--enable-static",
            "--enable-shared",
            "--with-compat",
            "--bsd",
            "--with-gmp",
            "--with-antlr-dir=#{Formula["libantlr3c"].opt_prefix}",
            "--prefix=#{prefix}"]
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"simple.cvc").write <<-EOS.undent
      x0, x1, x2, x3 : BOOLEAN;
      ASSERT x1 OR NOT x0;
      ASSERT x0 OR NOT x3;
      ASSERT x3 OR x2;
      ASSERT x1 AND NOT x1;
      % EXPECT: valid
      QUERY x2;
    EOS
    result = shell_output "#{bin}/cvc4 #{(testpath/"simple.cvc")}"
    assert_match /valid/, result
    (testpath/"simple.smt").write <<-EOS.undent
      (set-option :produce-models true)
      (set-logic QF_BV)
      (define-fun s_2 () Bool false)
      (define-fun s_1 () Bool true)
      (assert (not s_1))
      (check-sat)
    EOS
    result = shell_output "#{bin}/cvc4 --lang smt #{(testpath/"simple.smt")}"
    assert_match /unsat/, result
  end
end
