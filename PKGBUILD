# Maintainer: jancchi <jancchi.the.rock@gmail.com>
pkgname=random-wallpaper-git # -git suffix is standard for dev versions
pkgver=r6.c8245cc            # This will be auto-updated
pkgrel=1
pkgdesc="A script to manage wallpaper history and transitions in Hyprland"
arch=('any')
license=('MIT')
depends=('bash' 'swww' 'matugen' 'hyprland' 'git')
makedepends=('git')
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
source=("${pkgname}::git+https://github.com/jancchi/random-wallpaper.git")
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"

  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$pkgname"
  
  install -Dm755 "random-wallpaper.sh" "${pkgdir}/usr/bin/random-wallpaper"

  find templates -type f -exec install -Dm644 "{}" "${pkgdir}/usr/share/random-wallpaper/{}" \;
}
