class Ferry < Formula
  desc "Guarded two-way mirror between a NAS folder and OneDrive"
  homepage "https://github.com/stphung/ferry"
  url "https://github.com/stphung/ferry/archive/refs/tags/v0.7.7.tar.gz"
  sha256 "01325178ed4dc1697f668855edc9fa1b6b99f01784188fee07ef05b28e8c8cf9"
  license "MIT"
  head "https://github.com/stphung/ferry.git", branch: "main"

  # date -v, launchctl, osascript and stty are used freely.
  depends_on :macos

  # rclone is the whole engine, not an optional extra. Installing it here is
  # the point of the tap: a new Mac needs `brew install stphung/tap/ferry`
  # and nothing else before `ferry setup`.
  depends_on "rclone"

  def install
    # Ferry.app is built from source here — every brew user has the CLT, and a
    # locally built, ad-hoc-signed app has no Gatekeeper friction. The bundle
    # lands in share/ferry/; `ferry app install` copies it to ~/Applications.
    # --disable-sandbox is for SwiftPM's own manifest sandbox, which cannot
    # nest inside Homebrew's; the brew sandbox still confines this build.
    system "make", "app", "SWIFT_BUILD_FLAGS=--disable-sandbox"
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

      For the menu bar indicator (a native app, built during this install):
        ferry app install

      IMPORTANT when removing ferry: run this FIRST, or the launchd agent
      and menu bar plugin are left behind. Homebrew cannot do it for you --
      formulae have no uninstall hook.
        ferry uninstall
    EOS
  end

  test do
    assert_match "ferry #{version}", shell_output("#{bin}/ferry --version")
    # An unknown command must fail loudly rather than do something surprising.
    assert_match "unknown command", shell_output("#{bin}/ferry nonsense 2>&1", 1)
    # The config parser rejects unknown keys rather than ignoring them; that is
    # what stops a typo silently disarming a safety rail.
    # The app bundle must have shipped alongside the script.
    assert_path_exists pkgshare/"Ferry.app/Contents/MacOS/Ferry"
    (testpath/"config").write("NONSENSE=1\n")
    output = shell_output("FERRY_CONFIG=#{testpath}/config #{bin}/ferry status 2>&1", 1)
    assert_match "NONSENSE", output
  end
end
