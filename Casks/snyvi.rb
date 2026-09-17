cask "snyvi" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.0.1"
  sha256 arm:   "7889bfb0861742f5889a23dd199421e31cc8689386fa87135a2bcda7d08267e1",
         intel: "ba8370fb0204f0852c2c66d983de046351563b1226310f8b17c7db7f3fa7ea93"

  url "https://github.com/snymrova/snyvi/releases/download/v#{version}/snyvi-#{version}-#{arch}-apple-darwin.tar.gz",
      verified: "github.com/snymrova/snyvi/"
  name "snyvi"
  desc "Fast, beautiful viewer for the documents your agents produce"
  homepage "https://mrova.rocks/snyvi"

  depends_on macos: ">= :big_sur"

  app "snyvi-#{version}-#{arch}-apple-darwin/snyvi.app"
  # The command line, from inside the bundle that was just installed. One
  # download carries the window and the CLI, so `brew install --cask snyvi`
  # leaves the reader with both `snyvi` and something to double-click.
  binary "#{appdir}/snyvi.app/Contents/MacOS/snyvi"

  # See the header of packaging/homebrew.sh: ad-hoc signed, so without this the
  # first open is refused as coming from an unidentified developer.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/snyvi.app"]
  end

  # The daemon outlives the window, and an upgrade that swaps the binary under
  # a running one leaves the old code serving. Stop it first; `snyvi stop` is
  # the same command the reader would type.
  uninstall quit:   "rocks.ohmydog.snyvi",
            script: {
              executable:   "#{appdir}/snyvi.app/Contents/MacOS/snyvi",
              args:         ["stop"],
              must_succeed: false,
            }

  # The library is the reader's documents. It is never removed by an
  # uninstall, only by `brew zap`, which says out loud that it deletes data.
  zap trash: [
    "~/Library/Application Support/snyvi",
    "~/Library/Application Support/rocks.ohmydog.snyvi",
    "~/Library/Saved Application State/rocks.ohmydog.snyvi.savedState",
    "~/Library/WebKit/rocks.ohmydog.snyvi",
  ]
end
