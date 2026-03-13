cask "hoist" do
  version :latest
  sha256 :no_check

  url "https://github.com/aaabramov/Hoist/releases/latest/download/Hoist.dmg"
  name "Hoist"
  desc "Automatically raises and focuses windows on mouse hover"
  homepage "https://github.com/aaabramov/Hoist"

  app "Hoist.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Hoist.app"]
  end

  uninstall quit: "com.iamandrii.hoist"

  zap trash: "~/.config/Hoist"
end
