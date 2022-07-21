<script context="module" lang="ts">
  import pt_labels from '$lib/consts/postag_labels.json'
  const v_kbd = ['q', '@', '#', '$', '%', '^']
  const p_kbd = ['-', '=']

  function similar_tags(ptag: string) {
    switch (ptag) {
      case '_':
        return ['n', 'a', 'v']

      case 'ng':
      case 'nl':
      case 'np':
        return ['n']

      case 'Nz':
        return ['Nr', 'Na']

      case 'Na':
        return ['Nr', 'Nz']

      case 'n':
        return ['na', 'nt']

      case 'na':
        return ['n', 'an']

      case 'a':
        return ['ab', 'an']

      case 'ab':
        return ['a', 'al']

      case 'an':
        return ['a', 'na']

      case 'ad':
        return ['a', 'd']

      case 'v':
        return ['vi', 'vn']

      case 'vd':
        return ['v', 'd']

      case 'vn':
        return ['v', 'n']

      case 'vi':
        return ['v', 'vo']

      case 'vg':
        return ['v', 'kv']

      case 'r':
      case 'rr':
      case 'ry':
      case 'rz':
        return ['rr', 'rz', 'ry']

      case 'al':
        return ['a', 'b']

      case 'vl':
        return ['al', 'nl']

      case 'i':
      case 'il':
        return ['nl', 'al']

      case 'm':
      case 'q':
      case 'mp':
        return ['m', 'q', 'mq']

      case 'c':
      case 'cc':
      case 'd':
        return ['d', 'c', 'cc']

      case 'xe':
      case 'xy':
      case 'xo':
        return ['xe', 'xy', 'xo']

      case 'k':
      case 'ka':
      case 'kn':
      case 'kv':
        return ['ka', 'kn', 'kv']

      default:
        return ['n', 'v', 'a']
    }
  }
</script>

<script lang="ts">
  import { hint } from './_shared'

  import { SIcon } from '$gui'
  import type { VpTerm } from '$lib/vp_term'

  export let vpterm: VpTerm
  export let dname = 'combine'

  $: val_hints = gen_val_hints(vpterm.init.h_vals || [], vpterm.val.trim())
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

  $: tag_hints = gen_tag_hints(dname, vpterm)

  function gen_tag_hints(dname: string, vpterm: VpTerm): string[] {
    if (dname == 'hanviet' || dname == 'tradsim') return []
    const output = vpterm.init.h_tags || []
    const curr_ptag = vpterm.ptag

    if (dname.startsWith('-')) output.push('Nr', 'Na')
    if (output.length < 3) output.push(...similar_tags(curr_ptag))
    return output.filter((x, i, s) => x && x != curr_ptag && s.indexOf(x) == i)
  }

  // show_mode = 0 => show minimal
  // show_mode = 1 => show vals, hide tags
  // show_mode = 2 => show tags, hide vals
  var show_mode = 0
  $: if (vpterm) show_mode = 0
</script>

<div hidden={true}>
  <button data-kbd="~" on:click={() => (vpterm.val = vpterm.o_val)} />
  <button data-kbd="[" on:click={() => (vpterm.ptag = 'Nr')} />
  <button data-kbd="]" on:click={() => (vpterm.ptag = 'Na')} />
  <button data-kbd="." on:click={() => (vpterm.ptag = 'Nz')} />
  <button data-kbd="/" on:click={() => (vpterm.ptag = 'Nw')} />
  <button data-kbd=";" on:click={() => (vpterm.ptag = 'al')} />
  <button data-kbd="'" on:click={() => (vpterm.ptag = 'vl')} />
  <button data-kbd="n" on:click={() => (vpterm.ptag = 'n')} />
</div>

<div class="wrap">
  <div class="hints" class:_expand={show_mode > 0}>
    {#each val_hints.slice(0, val_limit) as val, idx}
      <button
        class="hint"
        class:_base={val == vpterm.init.b_val}
        class:_priv={val == vpterm.init.u_val}
        data-kbd={v_kbd[idx]}
        on:click={() => (vpterm.val = val)}>{val}</button>
    {/each}

    {#if val_hints.length > val_limit}
      <button
        class="hint _icon"
        on:click={() => (show_mode = show_mode == 1 ? 0 : 1)}
        use:hint={'Ẩn/hiện các gợi ý nghĩa cụm từ'}
        ><SIcon name={show_mode == 1 ? 'minus' : 'plus'} /></button>
    {/if}

    <div class="right">
      {#each tag_hints.slice(0, 2) as tag, idx (tag)}
        <button
          class="hint _ptag"
          class:_base={tag == vpterm.init.b_ptag}
          class:_priv={tag == vpterm.init.u_ptag}
          data-kbd={p_kbd[idx]}
          on:click={() => (vpterm.ptag = tag)}>{pt_labels[tag] || tag}</button>
      {/each}

      {#if tag_hints.length > 2}
        <button
          class="hint _icon"
          on:click={() => (show_mode = show_mode == 2 ? 0 : 2)}
          use:hint={'Ẩn/hiện các gợi ý thể loại'}
          ><SIcon name={show_mode == 2 ? 'minus' : 'plus'} /></button>
      {/if}
    </div>
  </div>

  {#if show_mode == 1}
    <div class="extra">
      {#each val_hints.slice(val_limit) as val}
        <button
          class="hint"
          class:_base={val == vpterm.init.b_val}
          class:_priv={val == vpterm.init.u_val}
          on:click={() => (vpterm.val = val)}>{val}</button>
      {/each}
    </div>
  {:else if show_mode == 2}
    <div class="extra _tag">
      {#each tag_hints.slice(2) as tag}
        <button
          class="hint _ptag"
          class:_base={tag == vpterm.init.b_ptag}
          class:_priv={tag == vpterm.init.u_ptag}
          on:click={() => (vpterm.ptag = tag)}>{pt_labels[tag] || tag}</button>
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
    top: 100%;
    left: 0;
    right: 0;
    @include border($loc: bottom);
    @include bdradi($loc: bottom);
    @include bgcolor(secd);

    &._tag {
      justify-content: end;
    }
  }

  .right {
    margin-left: auto;
    padding-left: 0.5rem;
    @include flex();
  }

  // prettier-ignore
  .hint {
    // display: inline-flex;
    // align-items: center;
    cursor: pointer;
    padding: 0 .2rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null, $style: '-');

    &._ptag {
      font-size: em(13px, 14px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }

    &._icon {
      margin-left: -.25rem;
      margin-right: -.25rem;
      @include fgcolor(mute);
    }

    :global(svg) {
      margin-top: -0.2rem;
    }
  }
</style>
