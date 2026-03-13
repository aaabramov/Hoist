cask "autoraise" do
  version :latest
  sha256 :no_check

  url "https://github.com/aaabramov/AutoRaise/releases/latest/download/AutoRaise.dmg"
  name "AutoRaise"
  desc "Automatically raises and focuses windows on mouse hover"
  homepage "https://github.com/aaabramov/AutoRaise"

  app "AutoRaise.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/AutoRaise.app"]
  end

  uninstall quit: "com.iamandrii.autoraise"

  zap trash: "~/.config/AutoRaise"
end
