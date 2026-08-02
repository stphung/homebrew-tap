class Salvage < Formula
  desc "If I delete this, what do I lose? Content-based backup coverage check"
  homepage "https://github.com/stphung/salvage"
  url "https://github.com/stphung/salvage/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "fe3c442c4c88b162e1ecd14b1152b1e002924f0a3ef385e988a8ffe56ae6d020"
  # No license declared: the repo carries no LICENSE file, same as ferry.
  head "https://github.com/stphung/salvage.git", branch: "main"

  # salvage is a front end to rmlint's checksum matching, formatted with jq.
  # Neither is optional, and `make deps` can only check for them.
  depends_on "jq"
  depends_on "rmlint"

  def install
    # The Makefile's layout already matches Homebrew's: bin, share/man/man1,
    # share/zsh/site-functions, share/bash-completion/completions.
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "salvage #{version}", shell_output("#{bin}/salvage --version")

    # The real contract: a file whose content exists in the reference is
    # matched despite a different name and path; one that does not is
    # reported, and the exit status says so.
    (testpath/"target").mkpath
    (testpath/"ref/nested").mkpath
    (testpath/"target/renamed.txt").write("shared payload")
    (testpath/"ref/nested/original.dat").write("shared payload")
    (testpath/"target/only-here.txt").write("unique payload")

    output = shell_output("#{bin}/salvage #{testpath}/target -r #{testpath}/ref 2>/dev/null", 1)
    assert_equal "only-here.txt", output.strip
  end
end
