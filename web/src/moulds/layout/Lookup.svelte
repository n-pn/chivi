<script context="module">
  async function get_hanviet(line) {
    const res = await fetch(`/api/hanviet?line=${line}`)
    const data = await res.json()

    const hanviet = []
    let idx = 0
    for (const [key, val, dic] of data) {
      if (dic == 0) {
        hanviet.push([val, -1])
        idx += key.length
      } else {
        for (let v of val.split(' ')) {
          hanviet.push([v, idx])
          idx += 1
        }
      }
    }

    return hanviet
  }

  async function get_entries(line, from = 0) {
    // const res = await fetch('/api/inspect', {
    //   method: 'POST',
    //   headers: { 'Content-Type': 'application/json' },
    //   body: JSON.stringify({ t: inp }),
    // })

    // TODO: add udic
    const res = await fetch(`/api/lookup?line=${line}&from=${from}`)
    const entries = await res.json()

    return entries
  }

  function render_line(tokens, from, upto) {
    let res = ''
    for (const [val, idx] of tokens) {
      if (idx < 0) res += val
      else {
        let klass = 'active'
        if (idx < from || idx >= upto) klass = ''

        res += `<x-c class="${klass}" data-i="${idx}">${val}</x-c>`
      }
    }

    return res
  }
</script>

<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  export let active = true
  export let text = ''
  export let from = 0

  let hanviet = []
  let entries = []
  let upto = 0

  $: chinese = text.split('').map((x, i) => [x, i])
  $: if (fetch && text !== '') lookup(text, from)

  async function lookup(text, from) {
    hanviet = await get_hanviet(text)
    entries = await get_entries(text, from)
    if (entries.length > 0) upto = from + +entries[0][0]
  }

  function handle_click(event) {
    const target = event.target
    if (target.nodeName !== 'X-C') return
    from = +target.dataset.i
  }

  function chinese_entry(from, upto) {
    return chinese
      .slice(from, upto)
      .map(x => x[0])
      .join('')
  }

  // function hanviet_text(idx, length) {
  //   let index = 0
  //   while (hanviet[index][1] !== idx) index += 1
  //   if (index + length >= hanviet.length) return ''

  //   let output = ''
  //   while (hanviet[index][1] < idx + length) {
  //     output += hanviet[index][0]
  //     index += 1
  //   }
  //   return output.trim().toLowerCase()
  // }

  function handle_keypress(e) {
    if (e.keyCode != 92) return
    active = !active
  }
</script>

<style lang="scss">
  $sidebar-width: 30rem;

  aside {
    position: fixed;
    display: block;
    top: 0;
    right: 0;
    width: $sidebar-width;
    // min-width: 20rem;
    max-width: 90vw;

    height: 100%;
    z-index: 900;

    @include bgcolor(white);
    @include shadow(2);

    // transition: transform 0.1s ease;
    transform: translateX(100%);
    &._active {
      transform: translateX(0);
    }
  }

  $zh-height: 4.5rem;
  $hv-height: 5.875rem;
  $hd-height: 3rem;

  header {
    display: flex;
    height: $hd-height;
    padding: 0.375rem 0.75rem;
    border-bottom: 1px solid color(neutral, 2);

    :global(svg) {
      display: inline-block;
      // vertical-align: top;
      vertical-align: text-top;
      width: 1.25rem;
      height: 1.25rem;
    }

    h2 {
      // display: flex;
      margin-right: auto;
      font-weight: 500;
      text-transform: uppercase;
      line-height: $hd-height - 0.75rem;
      @include color(neutral, 6);
      @include font-size(sm);
    }

    button {
      // margin-right: 0.75rem;
      padding: 0 0.5rem;
      @include color(neutral, 6);
      @include bgcolor(none);
      @include hover {
        @include color(primary, 6);
      }
    }
  }

  section {
    height: calc(100% - #{$zh-height + $hv-height + $hd-height});
    overflow-y: scroll;
  }

  :global(x-c) {
    cursor: pointer;
    @include hover {
      @include color(primary, 5);
    }

    &.active {
      @include color(primary, 5);
    }
  }

  h4 {
    font-weight: 500;
    text-transform: uppercase;
    @include color(neutral, 6);
    @include font-size(sm);
  }

  .input {
    overflow-y: scroll;
    line-height: 1.25rem;
    padding: 0.375rem 0.75rem;
    border-bottom: 1px solid color(neutral, 3);

    @include bgcolor(neutral, 1);
    @include font-family(sans);

    &._zh {
      max-height: $zh-height;
    }

    &._hv {
      max-height: $hv-height;
    }
  }

  h3 {
    // margin-top: 0.5rem;
    font-weight: bold;
    @include font-size(md);
    @include color(neutral, 7);
  }

  .entry {
    padding: 0.375rem 0.75rem;
    // padding-top: 0;

    & + & {
      border-top: 1px solid color(neutral, 3);
    }
  }

  .item {
    @include clearfix;
    & + & {
      margin-top: 0.5rem;
    }
  }

  .term {
    line-height: 1.375rem;
    margin-top: 0.25rem;
  }
</style>

<svelte:window on:keypress={handle_keypress} />

<aside class:_active={active}>
  <header>
    <h2>Giải nghĩa</h2>

    <button on:click={() => (active = !active)}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round">
        <path
          d="M17.85 10.2l-4.24 5.65m4.24-5.66L13.6 5.95m4.24 4.24a2 2 0 0 0 2.83
          0l.7-.7-7.07-7.08-.7.71a2 2 0 0 0 0 2.83m0 9.9l-5.66-5.66m5.66
          5.66s1.76 2.47-.71 4.95L3 10.9c2.47-2.48 4.95-.7 4.95-.7m0
          0l5.66-4.25M7.95 15.85l-4.24 4.24" />
      </svg>
    </button>

    <button on:click={() => (active = !active)}>
      <MIcon m-icon="x" />
    </button>

  </header>

  <div class="input _zh" on:click={handle_click}>
    {@html render_line(chinese, from, upto)}
  </div>

  <div class="input _hv" on:click={handle_click}>
    {@html render_line(hanviet, from, upto)}
  </div>

  <section>
    {#each entries as [len, items]}
      <div class="entry">
        <h3>{chinese_entry(from, from + len)}</h3>
        {#each items as [name, value]}
          <div class="item">
            <h4>{name}</h4>
            {#each value.split('\n') as line}
              <p class="term">{line}</p>
            {/each}
          </div>
        {/each}
      </div>
    {/each}
  </section>
</aside>
