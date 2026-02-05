# Maintainer: jancchi <jancchi.the.rock@gmail.com>
pkgname=random-wallpaper
pkgver=r11.d86ec98
pkgrel=1
pkgdesc="A script to manage wallpaper history and transitions in Hyprland with Matugen"
arch=('any')
license=('MIT')
depends=('bash' 'swww' 'matugen' 'hyprland' 'git')
makedepends=('git')
provides=("random-wallpaper")
conflicts=("random-wallpaper")
source=("${pkgname}::git+https://github.com/jancchi/random-wallpaper.git")
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  # Go into the git clone directory
  cd "${srcdir}/${pkgname}"
  
  # 1. Install the script (renaming to random-wallpaper)
  install -Dm755 "random-wallpaper.sh" "${pkgdir}/usr/bin/random-wallpaper"

  # 2. Install templates to /usr/share/random-wallpaper/templates/
  # This matches the script's GLOBAL_TEMPLATES variable
  local share_dir="${pkgdir}/usr/share/random-wallpaper/templates"
  mkdir -p "$share_dir"
  
  # Copy config/matugen toml
  if [ -f "templates/config.toml" ]; then
      install -Dm644 "templates/config.toml" "$share_dir/config.toml"
  elif [ -f "templates/matugen.toml" ]; then
      install -Dm644 "templates/matugen.toml" "$share_dir/config.toml"
  fi

  # Copy all .conf and .css files
  find templates -type f \( -name "*.conf" -o -name "*.css" \) -exec install -Dm644 "{}" "$share_dir/" \;
}
