// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const colors = require("tailwindcss/colors"); // <-- ADD THIS LINE
const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
	content: [
		"./js/**/*.js",
		"../lib/built_with_phoenix_web.ex",
		"../lib/built_with_phoenix_web/**/*.*ex",
		"../deps/ash_authentication_phoenix/**/*.*ex",
	],
	theme: {
		extend: {
			colors: {
				brand: "#FD4F00",

				primary: colors.orange,
				secondary: colors.pink,
				success: colors.green,
				danger: colors.red,
				warning: colors.yellow,
				info: colors.sky,

				// Options: slate, gray, zinc, neutral, stone
				gray: colors.stone,
			},
		},
	},
	plugins: [
		require("@tailwindcss/forms"),

		plugin(function ({ matchUtilities, theme }) {
			matchUtilities(
				{
					"grid-fill-cols": (value) => {
						const [minValue, max] = value.split(" ");
						const maxValue = max || "1fr";

						return {
							"--min": minValue,
							"--max": maxValue,
							gridTemplateColumns: `repeat(auto-fill, minmax(var(--min), var(--max)))`,
						};
					},
					"grid-fit-cols": (value) => {
						const [minValue, max] = value.split(" ");
						const maxValue = max || "1fr";

						return {
							"--min": minValue,
							"--max": maxValue,
							gridTemplateColumns: `repeat(auto-fit, minmax(var(--min), var(--max)))`,
						};
					},
				},
				{ values: theme("gridAutoCols") }
			);
		}),
		// Allows prefixing tailwind classes with LiveView classes to add rules
		// only when LiveView classes are applied, for example:
		//
		//     <div class="phx-click-loading:animate-ping">
		//
		plugin(({ addVariant }) =>
			addVariant("phx-click-loading", [
				".phx-click-loading&",
				".phx-click-loading &",
			])
		),
		plugin(({ addVariant }) =>
			addVariant("phx-submit-loading", [
				".phx-submit-loading&",
				".phx-submit-loading &",
			])
		),
		plugin(({ addVariant }) =>
			addVariant("phx-change-loading", [
				".phx-change-loading&",
				".phx-change-loading &",
			])
		),

		// Embeds Heroicons (https://heroicons.com) into your app.css bundle
		// See your `CoreComponents.icon/1` for more information.
		//
		plugin(function ({ matchComponents, theme }) {
			let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
			let values = {};
			let icons = [
				["", "/24/outline"],
				["-solid", "/24/solid"],
				["-mini", "/20/solid"],
				["-micro", "/16/solid"],
			];
			icons.forEach(([suffix, dir]) => {
				fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
					let name = path.basename(file, ".svg") + suffix;
					values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
				});
			});
			matchComponents(
				{
					hero: ({ name, fullPath }) => {
						let content = fs
							.readFileSync(fullPath)
							.toString()
							.replace(/\r?\n|\r/g, "");
						let size = theme("spacing.6");
						if (name.endsWith("-mini")) {
							size = theme("spacing.5");
						} else if (name.endsWith("-micro")) {
							size = theme("spacing.4");
						}
						return {
							[`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
							"-webkit-mask": `var(--hero-${name})`,
							mask: `var(--hero-${name})`,
							"mask-repeat": "no-repeat",
							"background-color": "currentColor",
							"vertical-align": "middle",
							display: "inline-block",
							width: size,
							height: size,
						};
					},
				},
				{ values }
			);
		}),
	],
};
