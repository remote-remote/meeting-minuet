// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

const sizeMods = ['sm', 'md', 'lg', 'xl', '2xl', 'xs', 'sm:max-lg', 'lg:max-xl']

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/meeting_minuet_web.ex",
    "../lib/meeting_minuet_web/**/*.*ex"
  ],
  safelist: [
    { pattern: /col-start-/, variants: sizeMods },
    { pattern: /col-span-/, variants: sizeMods },
    { pattern: /row-start-/, variants: sizeMods },
    { pattern: /row-span-/, variants: sizeMods },
    { pattern: /grid-cols-/, variants: sizeMods },
    { pattern: /grid-rows-/, variants: sizeMods },
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          '50': '#f3f7fc',
          '100': '#e6eff8',
          '200': '#c7ddf0',
          '300': '#96c1e3',
          '400': '#5da1d3',
          '500': '#3985be',
          '600': '#2869a1',
          '700': '#225482',
          '800': '#20496c',
          '900': '#1f3e5b',
          '950': '#193049',
        },
        secondary: {
          '50': '#f5f4f1',
          '100': '#e5e3dc',
          '200': '#ccc9bc',
          '300': '#afa995',
          '400': '#988e77',
          '500': '#8e836d',
          '600': '#756959',
          '700': '#5f5449',
          '800': '#524841',
          '900': '#48403b',
          '950': '#282220',
        },
        action: {
          '50': '#fffaec',
          '100': '#fff3d3',
          '200': '#ffe4a5',
          '300': '#ffce6d',
          '400': '#ffae32',
          '500': '#ff930a',
          '600': '#ff7b00',
          '700': '#cc5902',
          '800': '#a1450b',
          '900': '#823b0c',
          '950': '#461b04',
        },
      }
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
