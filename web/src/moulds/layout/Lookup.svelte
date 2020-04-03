<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  export let input = ''
  export let offset = 0
  export let active = true

  $: if (input !== '' && fetch) fetch_inspect(input)

  let chinese = []
  let hanviet = []
  let entries = []
  $: current = entries[offset] || []

  function render_line(tokens, offset) {
    const current = entries[offset] || [[1]]
    // if (current.length === 0) return

    const range = offset + +current[0][0]

    let output = ''
    for (let [val, pos] of tokens) {
      if (pos < 0) output += val
      else {
        let klass = pos >= offset && pos < range ? ' _active' : ''
        output += `<ip-chr class="${klass}" data-i="${pos}">${val}</ip-chr>`
      }
    }

    return output
  }

  function handle_click(event) {
    const target = event.target
    if (target.nodeName !== 'IP-CHR') return

    const new_offset = +target.dataset.i
    if (new_offset < 0 || new_offset >= chinese.length) return
    if (entries[new_offset].length === 0) return

    offset = new_offset
  }

  function chinese_text(offset, length) {
    return chinese.slice(offset, offset + length).join('')
  }

  function hanviet_text(offset, length) {
    let index = 0
    while (hanviet[index][1] !== offset) index += 1
    if (index + length >= hanviet.length) return ''

    let output = ''
    while (hanviet[index][1] < offset + length) {
      output += hanviet[index][0]
      index += 1
    }
    return output.trim().toLowerCase()
  }

  function handle_keypress(e) {
    if (e.keyCode != 92) return
    active = !active
  }

  async function fetch_inspect(inp) {
    const res = await fetch('/api/inspect', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ t: inp }),
    })

    const data = await res.json()
    chinese = data.chinese
    hanviet = data.hanviet
    entries = data.entries
  }
</script>

<style lang="scss">
  $sidebar-width: 24rem;

  aside {
    position: fixed;
    display: block;
    top: 0;

    right: -$sidebar-width;
    width: $sidebar-width;

    height: 100%;
    z-index: 999;

    @include bgcolor(white);
    @include shadow(lg);

    // transition: transform 0.1s ease;

    &._active {
      transform: translateX(-$sidebar-width);
    }
  }

  $zh-height: 4.5rem;
  $hv-height: 5.75rem;
  $hd-height: 3rem;

  header {
    display: flex;
    height: $hd-height;
    padding: 0.5rem 0;
    // @include bgcolor(neutral, 1);
    border-bottom: 1px solid color(neutral, 2);

    :global(svg) {
      display: inline-block;
      vertical-align: text-top;
      width: 1rem;
      height: 1rem;
    }

    h2 {
      margin-left: 1rem;
      margin-right: auto;
      font-weight: 500;
      text-transform: uppercase;
      line-height: $hd-height - 1rem;
      @include color(neutral, 6);
      @include font-size(sm);
    }

    button {
      margin-left: auto;
      margin-right: 0.5rem;
      @include color(neutral, 6);
      @include bgcolor(transparent);
      @include hover {
        @include color(primary, 6);
      }
    }
  }

  section {
    height: calc(100% - #{$zh-height + $hv-height + $hd-height});
    overflow-y: scroll;
  }

  :global(ip-chr) {
    @include hover {
      cursor: pointer;
      @include color(primary, 5);
    }

    &._active {
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
    padding: 0.5rem 1rem;
    border-bottom: 1px solid color(neutral, 3);

    @include bgcolor(neutral, 1);
    @include font-family(sans);

    &._zh {
      height: $zh-height;
    }

    &._hv {
      height: $hv-height;
    }
  }

  .entry {
    margin: 0;
    padding: 0 1rem;

    & + & {
      border-top: 1px solid color(neutral, 3);
    }

    h3 {
      margin-top: 0.5rem;
      font-weight: bold;
      @include font-size(lg);
      @include color(neutral, 7);
    }
  }

  .item {
    margin: 0.5rem 0;
    @include clearfix;
  }

  .term {
    line-height: 1.375rem;
    margin-top: 0.25rem;
  }
</style>

<svelte:window on:keypress={handle_keypress} />

<aside class:_active={active}>
  <header>
    <h2>
      <MIcon m-icon="compass" />
      <span>Giải nghĩa</span>
    </h2>

    <button on:click={() => (active = !active)}>
      <MIcon m-icon="x" />
    </button>
  </header>

  <div class="input _zh" on:click={handle_click}>
    {@html render_line(chinese.map((x, i) => [x, i]), offset)}
  </div>

  <div class="input _hv" on:click={handle_click}>
    {@html render_line(hanviet, offset)}
  </div>

  <section>
    {#each current as [len, item]}
      <div class="entry">
        <h3>{chinese_text(offset, +len)} [ {hanviet_text(offset, +len)} ]</h3>
        {#each item as [name, lines]}
          <div class="item">
            <h4>{name}</h4>
            {#each lines.split('\n') as line}
              <p class="term">{line}</p>
            {/each}
          </div>
        {/each}
      </div>
    {/each}
  </section>
</aside>
