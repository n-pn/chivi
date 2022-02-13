<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let value = ''
  export let name = 'mdform'
  export let placeholder = ''
  let input: HTMLTextAreaElement

  let old_value = ''

  function apply(type: string) {
    const { selectionStart: start, selectionEnd: end } = input

    switch (type) {
      case 'bold':
        return insert_text([start, end], '**')

      case 'italic':
        return insert_text([start, end], '_')

      case 'code':
        return insert_text([start, end], '`')

      case 'link':
        return insert_text([start, end], '[', '](url)')

      case 'heading':
        return insert_text(extend_range(start, end), '# ', '')

      case 'blockquote':
        return insert_text(extend_range(start, end), '> ', '')

      case 'list':
        return insert_text(extend_range(start, end), '- ', '')

      default:
        return
    }
  }

  function insert_text(
    [start, end]: [number, number],
    prefix: string,
    suffix = prefix
  ) {
    const text = input.value.substring(start, end)
    const data = text.split(/\r?\n|\r/).map((x) => prefix + x + suffix)

    input.focus()
    old_value = value

    input.setSelectionRange(start, end)
    input.setRangeText(data.join('\n'))

    const offset = prefix.length
    if (!text) {
      input.setSelectionRange(start + offset, end + offset * data.length)
    } else {
      const after = end + offset * data.length + suffix.length * data.length
      input.setSelectionRange(after, after)
    }
  }

  function extend_range(start: number, end: number): [number, number] {
    const chars = Array.from(value.replace(/\r\n?/g, '\n'))
    while (start > 0 && chars[start - 1] != '\n') start -= 1
    while (end < chars.length && chars[end] != '\n') end += 1
    return [start, end]
  }

  function handle_key(evt: KeyboardEvent) {
    if (!evt.ctrlKey) return

    switch (evt.key) {
      case 'z':
        if (old_value) {
          evt.preventDefault()
          input.value = old_value
        }
    }
  }

  const menu = [
    ['bold', '*', 'In đậm'],
    ['italic', '_', 'In nghiêng'],
    ['blockquote', '>', 'Trích dẫn'],
    ['code', '`', 'Đoạn code'],
    ['link', '[', 'Liên kết'],
    ['list', '-', 'Danh sách'],
    ['list-numbers', '+', 'Danh sách đánh số'],
  ]
</script>

<svelte:window on:keydown={handle_key} />

<md-form>
  <md-head>
    <md-menu>
      {#each menu as [name, kbd, tip]}
        <button on:click={() => apply(name)} data-kbd={kbd} data-tip={tip}
          ><SIcon {name} /></button>
      {/each}
    </md-menu>
  </md-head>

  <textarea {name} {placeholder} lang="vi" bind:value bind:this={input} />
</md-form>

<style lang="scss">
  md-form {
    display: block;
    max-width: 100%;

    @include fgcolor(main);
    @include bgcolor(main);

    @include bdradi();
    @include border($width: 1px);

    &:focus,
    &:focus-within {
      @include bgcolor(tert);
      box-shadow: 0 0 0 1px color(primary, 5, 5);
    }
  }

  md-head {
    display: flex;
    height: 2rem;
    padding: 0 0.75rem;
    @include bdradi($loc: top);
    @include border($loc: bottom);
    @include bgcolor(tert);
  }

  md-menu {
    display: flex;
    margin-left: auto;
  }

  button {
    background: none;
    height: 2rem;
    width: 1.875rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;

    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 5);
      @include bgcolor(secd);
    }
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 6rem;
    max-height: 80vh;
    border: 0;
    outline: 0;
    line-height: 1.5rem;
    background: transparent;
    padding: 0.375rem 0.75rem;
    // font-size: rem(17px);
    @include fgcolor(main);

    &::placeholder {
      font-style: italic;
      @include fgcolor(tert);
    }
  }
</style>
