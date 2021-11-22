<script context="module">
  const escape_tags = { '&': '&amp;', '"': '&quot;', "'": '&apos;' }

  function escape_html(str) {
    return str && str.replace(/[&<>]/g, (x) => escape_tags[x] || x)
  }

  export class Mtline {
    static parse_lines(input = '') {
      return input.split('\n').map((x) => new Mtline(x))
    }

    constructor(input) {
      this.data = this.parse(Array.from(input), 0)[0]
    }

    parse(chars, i = 0) {
      const data = []
      let term = []
      let word = ''

      while (i < chars.length) {
        const char = chars[i]
        i += 1

        switch (char) {
          case '〉':
            if (word) term.push(word)
            if (term.length > 0) data.push(term)
            return [data, i]

          case '〈':
            if (word) term.push(word)
            if (term.length > 0) data.push(term)
            const fold = chars[i]
            const [child, j] = this.parse(chars, i + 1)
            data.push([child, fold])
            i = j

            word = ''
            term = []

            break

          case '\t':
            if (word) term.push(word)
            if (term.length > 0) data.push(term)

            word = ''
            term = []

            break

          case 'ǀ':
            term.push(word)
            word = ''
            break

          default:
            word += char
        }
      }

      if (word) term.push(word)
      if (term.length > 0) data.push(term)

      return [data, i]
    }

    render_hv() {
      let res = ''

      for (const [val, dic, idx] of this.data) {
        if (val == ' ') {
          res += ' '
          continue
        }

        let chars = val.split(' ')

        res += `<c-g data-d=${dic}>`
        for (let j = 0; j < chars.length; j++) {
          if (j > 0) res += ' '
          const val = escape_html(chars[j])
          res += `<v-n data-d=2 data-i=${+idx + j} data-l=1>${val}</v-n>`
        }
        res += '</c-g>'
      }

      return res
    }

    get html() {
      this._html = this._html || this.render_cv(this.data, false)
      return this._html
    }

    get text() {
      this._text = this._text || this.render_cv(this.data, true)
      return this._text
    }

    render_cv(data = this.data, text = true) {
      let res = ''
      let lvl = 0

      for (const [val, dic, idx, len] of data) {
        if (Array.isArray(val)) {
          const inner = this.render_cv(val, text)

          if (text) res += inner
          else res += `<v-g data-d=${dic}>${inner}</v-g>`
          continue
        }

        if (val == ' ') {
          res += ' '
          continue
        }

        const fval = val[0]
        if (fval == '“' || fval == '‘') {
          lvl += 1
          res += '<em>'
        } else if (fval == '⟨') {
          res += '<cite>'
        }

        const esc = escape_html(val)

        if (text) res += esc
        else
          res += `<v-n data-d=${dic} data-i=${idx} data-l=${len}>${esc}</v-n>`

        const lval = val[val.length - 1]

        if (lval == '”' || lval == '’') {
          lvl -= 1
          res += '</em>'
        } else if (fval == '⟩') {
          res += '</cite>'
        }
      }

      while (lvl < 0) {
        res = '<em>' + res
        lvl++
      }

      while (lvl > 0) {
        res = res + '</em>'
        lvl--
      }

      return res
    }

    static render_zh(input) {
      let res = ''
      let idx = 0

      for (const key of Array.from(input)) {
        res += `<c-g data-d=1>`

        for (const k of Array.from(key)) {
          res += `<v-n data-d=2 data-i=${idx} data-l=1>${escape_html(k)}</v-n>`
          idx += 1
        }

        res += '</c-g>'
      }

      return res
    }
  }
</script>

<script>
  export let input
  export let focus = false
</script>

{@html focus ? input.html : input.text}

<style lang="scss" global>
  @mixin cv-node($color: blue) {
    cursor: pointer;
    // position: relative;

    @include tm-light {
      --active: #{color($color, 6)};
      --border: #{color($color, 4)};
    }

    @include tm-dark {
      --active: #{color($color, 4)};
      --border: #{color($color, 6)};
    }
  }

  v-n {
    background-position: bottom bottom;

    cv-data:hover &,
    cv-data.focus &,
    cv-data.debug &,
    &:hover,
    &.focus {
      background: linear-gradient(to top, var(--border) 1px, transparent 0);
    }

    &:hover,
    &.focus {
      color: var(--active);
    }

    // essence + fixture
    &[data-d='1'] {
      @include cv-node(gray);
      background: none !important;
    }

    // regular + public
    &[data-d='2'] {
      @include cv-node(blue);
    }

    // unique + public
    &[data-d='3'] {
      @include cv-node(orange);
    }

    // regular + private
    &[data-d='4'] {
      @include cv-node(teal);
    }

    // unique + private
    &[data-d='5'] {
      @include cv-node(red);
    }

    c-g & {
      cursor: pointer;
      // prettier-ignore
      &:hover, &.focus { color: var(--active); }
    }
  }

  // prettier-ignore
  @mixin vg-wrap($left: '{', $right: '}') {
    &:before, &:after { font-style: normal; }
    &:before { content: $left; }
    &:after { content: $right; }
  }

  v-g {
    --vgcolor: var(--fgmain);

    cv-data.debug & {
      background: none !important;

      // prettier-ignore
      &:before, &:after { color: var(--vgcolor); }
      @include vg-wrap('[', ']');

      v-n {
        color: var(--vgcolor);
        // prettier-ignore
        &:hover { color: var(--active); }
      }
    }

    &[data-d='0'],
    &[data-d='1'] {
      @include vg-wrap('', '');
    }

    $colors: (gray, green, blue, teal, orange, fuchsia, purple, pink, red);

    @for $i from 1 through 9 {
      &[data-d='#{$i}'] {
        $color: list.nth($colors, $i);
        --vgcolor: #{color($color, 5)};
      }
    }
  }
</style>
