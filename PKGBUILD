# Maintainer: jancchi <jancchi.the.rock@gmail.com>
pkgname=random-wallpaper
pkgver=r13.a4b48ab
pkgrel=1
pkgdesc="Wallpaper manager with automatic wallust templates"
arch=('any')
license=('MIT')
depends=('bash' 'swww' 'wallust' 'hyprland' 'git')
makedepends=('git')
source=("${pkgname}::git+https://github.com/jancchi/random-wallpaper.git")
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "${srcdir}/${pkgname}"
  
  # Install binary
  install -Dm755 "random-wallpaper.sh" "${pkgdir}/usr/bin/random-wallpaper"
  
  # Install templates
  local share_dir="${pkgdir}/usr/share/random-wallpaper/templates"
  mkdir -p "$share_dir"
  install -Dm644 templates/wallust.toml "$share_dir/wallust.toml"
  find templates -type f \( -name "*.conf" -o -name "*.css" -o -name "*.conf" \) -exec install -Dm644 "{}" "$share_dir/" \;
}
