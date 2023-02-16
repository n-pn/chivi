<script lang="ts">
  import { hint, type VpForm } from './_shared'

  import { SIcon } from '$gui'

  export let form: VpForm
  export let hanviet: string
  export let val_hints: string[]

  $: console.log(val_hints)

  $: hints = gen_val_hints(val_hints, form.val.trim())
  $: limit = gen_val_limit(hints)

  function gen_val_hints(hints: Array<string>, cval: string) {
    return hints.filter((x) => x && x != cval && x != hanviet)
  }

  function gen_val_limit(hints: Array<string>) {
    const max_chars = 40

    let char_count = 0
    for (let i = 0; i < hints.length; i++) {
      char_count += hints[i].length + 4
      if (char_count > max_chars) return i + 1
    }

    return hints.length
  }

  var show_all = false
  $: if (form) show_all = false

  const kbds = ['@', '#', '$', '%', '^']
</script>

<div class="wrap">
  <div class="hints" class:_expand={show_all}>
    <button
      class="hint"
      class:_prev={hanviet == form.init.val}
      data-kbd={'q'}
      on:click={() => (form.val = hanviet)}>{hanviet}</button>

    {#each hints.slice(0, limit) as val, idx}
      <button
        class="hint"
        class:_prev={val == form.init.val}
        data-kbd={kbds[idx]}
        on:click={() => (form.val = val)}>{val}</button>
    {/each}

    {#if hints.length > limit}
      <button
        class="hint _icon"
        on:click={() => (show_all = !show_all)}
        use:hint={'Ẩn/hiện các gợi ý nghĩa cụm từ'}
        ><SIcon name={show_all ? 'minus' : 'plus'} /></button>
    {/if}
  </div>

  {#if show_all}
    <div class="extra">
      {#each hints.slice(limit) as val}
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
