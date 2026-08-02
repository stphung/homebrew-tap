class Ferry < Formula
  desc "Guarded two-way mirror between a NAS folder and OneDrive"
  homepage "https://github.com/stphung/ferry"
  url "https://github.com/stphung/ferry/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "696979c45205931e777d8aa1378261f7ef6bea0f4646d4a63f074294ab4adc11"
  license "MIT"
  head "https://github.com/stphung/ferry.git", branch: "main"

  # date -v, launchctl, osascript and stty are used freely.
  depends_on :macos

  # rclone is the whole engine, not an optional extra. Installing it here is
  # the point of the tap: a new Mac needs `brew install stphung/tap/ferry`
  # and nothing else before `ferry setup`.
  depends_on "rclone"

  def install
    # The Makefile's layout already matches Homebrew's: bin, share/man/man1,
    # share/zsh/site-functions, share/bash-completion/completions.
    system "make", "install", "PREFIX=#{prefix}"
  end

  def caveats
    <<~EOS
      Set up the mirror with:
        ferry setup

      Then, once:
        ferry markers        # check both sides look right before confirming
        ferry resync -n      # preview establishing the pair
        ferry resync         # establish it

      And to run it on a schedule:
        ferry schedule install
    EOS
  end

  test do
    assert_match "ferry #{version}", shell_output("#{bin}/ferry --version")
    # An unknown command must fail loudly rather than do something surprising.
    assert_match "unknown command", shell_output("#{bin}/ferry nonsense 2>&1", 1)
    # The config parser rejects unknown keys rather than ignoring them; that is
    # what stops a typo silently disarming a safety rail.
    (testpath/"config").write("NONSENSE=1\n")
    output = shell_output("FERRY_CONFIG=#{testpath}/config #{bin}/ferry status 2>&1", 1)
    assert_match "NONSENSE", output
  end
end
