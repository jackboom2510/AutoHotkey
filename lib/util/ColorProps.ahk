#Include <core\Core>
class ColorProps {
    static CSS_LAB_COLORS := [
        { name: "black", L: 0.00, a: 0.00, b: 0.00 },
        { name: "white", L: 100.00, a: 0.00, b: 0.00 },
        { name: "gray", L: 53.59, a: 0.00, b: 0.00 },
        { name: "dimgray", L: 40.85, a: 0.00, b: 0.00 },
        { name: "darkgray", L: 60.16, a: 0.00, b: 0.00 },
        { name: "silver", L: 80.98, a: 0.00, b: 0.00 },
        { name: "gainsboro", L: 88.08, a: 0.00, b: 0.00 },
        { name: "whitesmoke", L: 96.22, a: 0.00, b: 0.00 },
        { name: "red", L: 53.23, a: 80.11, b: 67.22 },
        { name: "darkred", L: 35.84, a: 57.29, b: 42.14 },
        { name: "firebrick", L: 47.26, a: 57.39, b: 44.47 },
        { name: "crimson", L: 50.56, a: 67.97, b: 32.39 },
        { name: "indianred", L: 52.88, a: 37.00, b: 20.63 },
        { name: "lightcoral", L: 64.90, a: 44.20, b: 25.10 },
        { name: "salmon", L: 69.83, a: 44.75, b: 35.53 },
        { name: "hotpink", L: 63.85, a: 88.35, b: 5.43 },
        { name: "pink", L: 79.54, a: 44.22, b: 20.55 },
        { name: "orange", L: 74.94, a: 23.97, b: 78.85 },
        { name: "darkorange", L: 66.82, a: 47.93, b: 79.23 },
        { name: "gold", L: 81.33, a: 9.38, b: 80.05 },
        { name: "yellow", L: 97.14, a: -21.56, b: 94.48 },
        { name: "khaki", L: 83.21, a: -2.31, b: 47.16 },
        { name: "peru", L: 59.94, a: 16.29, b: 39.42 },
        { name: "lime", L: 87.73, a: -86.18, b: 83.18 },
        { name: "green", L: 46.23, a: -51.70, b: 49.90 },
        { name: "darkgreen", L: 29.56, a: -35.25, b: 34.39 },
        { name: "forestgreen", L: 37.95, a: -44.00, b: 40.73 },
        { name: "olive", L: 50.84, a: -12.44, b: 23.41 },
        { name: "chartreuse", L: 89.94, a: -73.35, b: 99.40 },
        { name: "limegreen", L: 58.00, a: -48.20, b: 46.33 },
        { name: "mediumseagreen", L: 59.88, a: -30.07, b: 2.22 },
        { name: "palegreen", L: 81.38, a: -29.28, b: 26.50 },
        { name: "cyan", L: 91.12, a: -48.07, b: -14.13 },
        { name: "teal", L: 44.91, a: -23.11, b: -4.39 },
        { name: "darkcyan", L: 46.59, a: -20.67, b: -3.85 },
        { name: "turquoise", L: 78.43, a: -24.84, b: -0.19 },
        { name: "skyblue", L: 67.89, a: -12.43, b: -28.98 },
        { name: "blue", L: 32.30, a: 79.19, b: -107.86 },
        { name: "navy", L: 13.12, a: 39.40, b: -50.93 },
        { name: "dodgerblue", L: 56.68, a: 14.28, b: -43.27 },
        { name: "steelblue", L: 49.63, a: -2.31, b: -21.41 },
        { name: "deepskyblue", L: 64.69, a: -12.38, b: -50.41 },
        { name: "magenta", L: 60.16, a: 98.25, b: -60.82 },
        { name: "purple", L: 34.00, a: 49.33, b: -47.41 },
        { name: "indigo", L: 20.90, a: 39.06, b: -48.42 },
        { name: "violet", L: 68.53, a: 42.50, b: -39.11 },
        { name: "mediumorchid", L: 60.16, a: 35.82, b: -33.51 },
        { name: "thistle", L: 79.18, a: 11.08, b: -5.73 },
        { name: "brown", L: 39.95, a: 32.09, b: 35.53 },
        { name: "saddlebrown", L: 30.65, a: 28.02, b: 32.08 },
        { name: "sienna", L: 46.12, a: 27.64, b: 35.61 },
        { name: "tan", L: 65.23, a: 16.89, b: 47.96 },
        { name: "burlywood", L: 75.38, a: 10.59, b: 33.72 },
        { name: "chocolate", L: 54.34, a: 30.49, b: 40.15 }
    ]
    __New(colorInput, shadeCount := 5, includeCoolWarm := false, includeHarmonies := true) {

        local r, g, b, h, s, l, v, h_hsl, s_hsl, l_hsl

        if (RegExMatch(colorInput, "^#?([0-9a-fA-F]{6})$", &match)) {
            hex := match[1]
            r := Integer("0x" SubStr(hex, 1, 2))
            g := Integer("0x" SubStr(hex, 3, 2))
            b := Integer("0x" SubStr(hex, 5, 2))
        }
        else if (RegExMatch(colorInput, "i)^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$", &match)) {
            r := match[1], g := match[2], b := match[3]
        }
        else if (RegExMatch(colorInput, "i)^hsl\(\s*([\d\.]+)\s*,\s*([\d\.]+)%\s*,\s*([\d\.]+)%\s*\)$", &match)) {
            h_hsl := match[1], s_hsl := match[2], l_hsl := match[3]

            s := s_hsl / 100
            l := l_hsl / 100
            h := h_hsl / 60

            if (s == 0) {
                r := g := b := Round(l * 255)
            }
            else {
                q := l < 0.5 ? l * (1 + s) : l + s - l * s
                p := 2 * l - q

                tToRgb(t) {
                    if (t < 0)
                        t += 6
                    if (t >= 6)
                        t -= 6
                    if (t < 1)
                        return p + (q - p) * t
                    if (t < 3)
                        return q
                    if (t < 4)
                        return p + (q - p) * (4 - t)
                    return p
                }

                r := Round(tToRgb(h + 2) * 255)
                g := Round(tToRgb(h) * 255)
                b := Round(tToRgb(h - 2) * 255)
            }

        }
        else {
            return { error: "Invalid color format: " colorInput }
        }

        r := Max(0, Min(255, r))
        g := Max(0, Min(255, g))
        b := Max(0, Min(255, b))
        hex := Format("{:02X}{:02X}{:02X}", r, g, b)

        luminance := 0.2126 * r + 0.7152 * g + 0.0722 * b
        theme := luminance < 128 ? "Dark" : "Light"

        maxColor := Max(r, g, b)
        minColor := Min(r, g, b)
        delta := maxColor - minColor

        l_rgb := (maxColor + minColor) / 2

        if (delta == 0) {
            h := 0
        }
        else {
            if (maxColor == r) {
                h := Mod(((g - b) / delta), 6)
            }
            else if (maxColor == g) {
                h := Mod((b - r) / delta + 2, 6)
            }
            else {
                h := Mod((r - g) / delta + 4, 6)
            }
            h := Mod((h * 60 + 360), 360)
        }

        s_l := (delta == 0) ? 0 : (l_rgb == 0 || l_rgb == 255) ? 0 : (delta / (255 - Abs(2 * l_rgb - 255))) * 100

        v := maxColor
        s_v := (maxColor == 0) ? 0 : (delta / maxColor) * 100

        var_R := this.rgbToXyz(r), var_G := this.rgbToXyz(g), var_B := this.rgbToXyz(b)
        X := var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
        Y := var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
        Z := var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505

        X_n := 95.047, Y_n := 100.000, Z_n := 108.883

        X_r := this.xyzToLab(X / X_n), Y_r := this.xyzToLab(Y / Y_n), Z_r := this.xyzToLab(Z / Z_n)
        L_lab := (116 * Y_r) - 16
        a_lab := 500 * (X_r - Y_r)
        b_lab := 200 * (Y_r - Z_r)

        gradient := []
        for i in [
            0,
            1,
            2,
            3,
            4
        ] {
            factor := i / (shadeCount - 1)
            shadeR := Round(r * (1 - factor))
            shadeG := Round(g * (1 - factor))
            shadeB := Round(b * (1 - factor))
            gradient.Push(Format("#{:02X}{:02X}{:02X}", shadeR, shadeG, shadeB))
        }

        colors := {}
        s_pct := Round(s_l)
        l_pct := Round(l_rgb / 255 * 100)

        if (includeHarmonies) {
            colors.complementary := this.hslToHex(Mod(h + 180, 360), s_pct, l_pct)

            colors.triadic := [
                this.hslToHex(h, s_pct, l_pct),
                this.hslToHex(Mod(h + 120, 360), s_pct, l_pct),
                this.hslToHex(Mod(h + 240, 360), s_pct, l_pct)
            ]

            colors.analogous := [
                this.hslToHex(h, s_pct, l_pct),
                this.hslToHex(Mod(h + 30, 360), s_pct, l_pct),
                this.hslToHex(Mod(h - 30 + 360, 360), s_pct, l_pct)
            ]

            colors.tetradic := [
                this.hslToHex(h, s_pct, l_pct),
                this.hslToHex(Mod(h + 90, 360), s_pct, l_pct),
                this.hslToHex(Mod(h + 180, 360), s_pct, l_pct),
                this.hslToHex(Mod(h + 270, 360), s_pct, l_pct)
            ]

            colors.monochromatic := [
                this.hslToHex(h, s_pct, Max(0, l_pct - 15)),
                this.hslToHex(h, s_pct, Max(0, l_pct - 30)),
                this.hslToHex(h, s_pct, Max(0, l_pct - 50)),
                this.hslToHex(h, s_pct, Min(100, l_pct + 15)),
                this.hslToHex(h, s_pct, Min(100, l_pct + 30)),
                this.hslToHex(h, s_pct, Min(100, l_pct + 50))
            ]
        }

        colors.warm := includeCoolWarm ? [
            Format("#{:02X}{:02X}{:02X}", Min(255, r + 20), g, Max(0, b - 20)),
            Format(
                "#{:02X}{:02X}{:02X}", Min(255, r + 40), g, Max(0, b - 40))
        ] : []

        colors.cool := includeCoolWarm ? [
            Format("#{:02X}{:02X}{:02X}", Max(0, r - 20), Min(255, g + 20), Min(255, b +
                20)),
            Format("#{:02X}{:02X}{:02X}", Max(0, r - 40), Min(255, g + 40), Min(255, b + 40))
        ] : []

        this.hex := "#" hex
        this.rgb := { r: r, g: g, b: b }
        this.rgbStr := Format("rgb({}, {}, {})", r, g, b)

        this.luminance := Round(luminance)
        this.theme := theme
        this.isLight := theme = "Light"

        this.hsl := { h: Round(h, 1), s: Round(s_l), l: Round(l_rgb / 255 * 100) }
        this.hslStr := Format("hsl({}, {}%, {}%)", Round(h, 1), Round(s_l), Round(l_rgb / 255 * 100))

        this.hsv := { h: Round(h, 1), s: Round(s_v), v: Round(v / 255 * 100) }
        this.hsvStr := Format("hsv({}, {}%, {}%)", Round(h, 1), Round(s_v), Round(v / 255 * 100))

        this.xyz := { x: Round(X, 3), y: Round(Y, 3), z: Round(Z, 3) }
        this.lab := { l: Round(L_lab, 3), a: Round(a_lab, 3), b: Round(b_lab, 3) }

        this.gradient := gradient
        this.colors := colors
        this.cssSafeName := this.getSafeName(L_lab, a_lab, b_lab)

        return this
    }

    hslToHex(h, s, l) {
        s /= 100, l /= 100
        h /= 60

        if (s == 0) {
            c := Round(l * 255)
            return Format("#{:02X}{:02X}{:02X}", c, c, c)
        }

        q := l < 0.5 ? l * (1 + s) : l + s - l * s
        p := 2 * l - q

        tToRgb(t) {
            if (t < 0)
                t += 6
            if (t >= 6)
                t -= 6
            if (t < 1)
                return p + (q - p) * t
            if (t < 3)
                return q
            if (t < 4)
                return p + (q - p) * (4 - t)
            return p
        }

        r := Round(tToRgb(h + 2) * 255)
        g := Round(tToRgb(h) * 255)
        b := Round(tToRgb(h - 2) * 255)

        return Format("#{:02X}{:02X}{:02X}", r, g, b)
    }

    rgbToXyz(comp) {
        comp := comp / 255
        comp := comp > 0.04045 ? ((comp + 0.055) / 1.055) ** 2.4 : comp / 12.92

        return comp * 100
    }

    xyzToLab(t) {
        t := t > 0.008856 ? t ** (1 / 3) : (7.787 * t) + (16 / 116)
        return t
    }

    DeltaE_Lab(L1, a1, b1, L2, a2, b2) {
        dL := L1 - L2, da := a1 - a2, db := b1 - b2
        return Sqrt(dL ** 2 + da ** 2 + db ** 2)
    }

    getSafeName(L, a, b) {

        minDistance := 9999
        closestName := "No recognized CSS name"

        for _, color in ColorProps.CSS_LAB_COLORS {
            distance := this.DeltaE_Lab(L, a, b, color.L, color.a, color.b)
            if (distance < minDistance) {
                minDistance := distance
                closestName := color.name
            }
        }

        return closestName
    }

    ToString() {
        return toString({ hex: this.hex, rgb: this.rgb, rgbStr: this.rgbStr, luminance: this.luminance, theme: this.theme, isLight: this
            .isLight, hsl: this.hsl, hslStr: this.hslStr, hsv: this.hsv, hsvStr: this.hsvStr, xyz: this.xyz, lab: this
                .lab, gradient: this
                .gradient, colors: this.colors, cssSafeName: this.cssSafeName })
    }
}
