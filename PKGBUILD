# Maintainer: jancchi <jancchi.the.rock@gmail.com>
pkgname=random-wallpaper
pkgver=1.0.1
pkgrel=1
pkgdesc="A script to manage wallpaper history and transitions in Hyprland"
arch=('any')
license=('MIT')
depends=('bash' 'swww' 'wallust' 'waybar' 'kitty' 'hyprland')
source=("random_wallpaper.sh")
sha256sums=('SKIP') # You can generate a real sum later with 'updpkgsums'

package() {
    # Create the /usr/bin directory in the package environment
    install -Dm755 "${srcdir}/random_wallpaper.sh" "${pkgdir}/usr/bin/random-wallpaper"
}