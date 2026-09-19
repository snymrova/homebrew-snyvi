cask "snyvi" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.1"
  sha256 arm:   "04f3abce164d9389c57283ab3e28aa2197d9138ee2e8071c7283fd99ba11ceb4",
         intel: "56dafb24f12eb89e4143a1ab7dfad6c957e9e761db511e89446ac909d3bbe40e"

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
