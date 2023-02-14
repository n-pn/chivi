<script lang="ts">
  import { hint, type VpForm } from './_shared'

  import { SIcon } from '$gui'

  export let form: VpForm
  export let hints: string[]

  export let refocus = () => {}

  $: val_hints = gen_val_hints(hints, form.val.trim())
  $: val_limit = gen_val_limit(val_hints)

  function gen_val_hints(hints: Array<string>, cval: string) {
    return hints.filter((x, i) => i == 0 || x != cval)
  }

  function gen_val_limit(val_hints: Array<string>) {
    const max_chars = 30

    let char_count = 0
    for (let i = 0; i < val_hints.length; i++) {
      char_count += val_hints[i].length + 4
      if (char_count > max_chars) return i + 1
    }

    return val_hints.length
  }

  var show_all = false
  $: if (form) show_all = false

  const kbds = ['q', '@', '#', '$', '%', '^']
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="wrap" on:click={refocus}>
  <div class="hints" class:_expand={show_all}>
    {#each val_hints.slice(0, val_limit) as val, idx}
      <button
        class="hint"
        class:_prev={val == form.init.val}
        data-kbd={kbds[idx]}
        on:click={() => (form.val = val)}>{val}</button>
    {/each}

    {#if val_hints.length > val_limit}
      <button
        class="hint _icon"
        on:click={() => (show_all = !show_all)}
        use:hint={'Ẩn/hiện các gợi ý nghĩa cụm từ'}
        ><SIcon name={show_all ? 'minus' : 'plus'} /></button>
    {/if}
  </div>

  {#if show_all}
    <div class="extra">
      {#each val_hints.slice(val_limit) as val}
        <button
          class="hint"
          class:_prev={val == form.init.val}
          on:click={() => (form.val = val)}>{val}</button>
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  .wrap {
    position: relative;
  }

  .hints {
    @include flex();
    @include ftsize(sm);

    padding: 0.25rem 0.5rem;
    height: 2rem;
  }

  .extra {
    @include flex();
    @include ftsize(xs);

    padding: 0.125rem 0.5rem;

    height: auto;
    flex-wrap: wrap;
    position: absolute;
    top: 1.875rem;
    left: 0;
    right: 0;
    @include border;
    @include bdradi($loc: bottom);
    @include bgcolor(secd);
  }

  .hint {
    // display: inline-flex;
    // align-items: center;
    cursor: pointer;
    padding: 0 0.2rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null, $style: '-');

    @include hover {
      @include fgcolor(primary, 5);
    }

    &._prev {
      @include fgcolor(secd);
      font-weight: 500;
    }

    &._icon {
      margin-left: -0.25rem;
      margin-right: -0.25rem;
      @include fgcolor(mute);
    }

    :global(svg) {
      margin-top: -0.2rem;
    }
  }
</style>
