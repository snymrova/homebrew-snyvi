cask "snyvi" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.3.0"
  sha256 arm:   "20dc2df1a8438e0fe743397ea078090756622c8e7e4b5660dfb32df4401067b0",
         intel: "33255d4d5858a28c6e888436648c26c14af66ee8748922c865bb2caf1a813410"

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
