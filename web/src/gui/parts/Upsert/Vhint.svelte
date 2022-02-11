<script context="module">
  import { ptnames } from '$parts/Postag.svelte'
  const v_kbd = ['q', '@', '#', '$', '%', '^']
  const p_kbd = ['-', '=']
</script>

<script>
  export let vpterm
  export let dname = 'combine'

  $: [ptag_priv, ptag_base, tag_hints] = gen_hint(dname, vpterm)

  function gen_hint(dname, vpterm) {
    if (dname == 'hanviet' || dname == 'tradsim') return ['', '', []]

    const priv = get_ptag(vpterm, true) || ''
    const base = get_ptag(vpterm, false) || ''
    const list = [priv, base, ...vpterm.h_tags, ...similar_tag(vpterm.ptag)]

    const filter = (x, i, s) => x && x != vpterm.ptag && s.indexOf(x) == i
    const hints = list.filter(filter)
    return [priv, base, hints.slice(0, 2)]
  }

  function similar_tag(ptag) {
    switch (ptag) {
      case '_':
        return ['n', 'a', 'v']

      case 'ng':
      case 'nl':
      case 'np':
        return ['n']

      case 'nz':
        return ['nr', 'nn']

      case 'nn':
        return ['nr', 'nz']

      case 'n':
        return ['na', 't']

      case 'na':
        return ['n', 'an']

      case 'a':
        return ['b', 'an']

      case 'b':
        return ['a', 'n']

      case 'an':
        return ['a', 'na']

      case 'ad':
        return ['a', 'd']

      case 'ag':
        return ['a', 'k']

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
        return ['nl', 'al']

      case 'm':
      case 'q':
      case 'mp':
        return ['m', 'q', 'mq']

      case 'c':
      case 'cc':
      case 'd':
        return ['d', 'c', 'cc']

      case 'e':
      case 'y':
      case 'o':
        return ['e', 'y', 'o']

      case 'k':
      case 'ka':
      case 'kn':
      case 'kv':
        return ['ka', 'kn', 'kv']

      default:
        return ['n', 'v', 'a']
    }
  }

  function get_ptag(vpterm, _priv) {
    if (_priv) return vpterm.val ? vpterm.u_ptag : ''
    return vpterm.b_ptag || vpterm.h_ptag
  }
</script>

<div hidden="hidden">
  <button data-kbd="~" on:click={() => (vpterm.val = vpterm.o_val)} />
  <button data-kbd="[" on:click={() => (vpterm.ptag = 'nr')} />
  <button data-kbd="]" on:click={() => (vpterm.ptag = 'nn')} />
  <button data-kbd="." on:click={() => (vpterm.ptag = 'nz')} />
  <button data-kbd="/" on:click={() => (vpterm.ptag = 'nw')} />
  <button data-kbd=";" on:click={() => (vpterm.ptag = 'al')} />
  <button data-kbd="'" on:click={() => (vpterm.ptag = 'vl')} />
  <button data-kbd="n" on:click={() => (vpterm.ptag = 'n')} />
</div>

<div class="hints">
  {#each vpterm.h_vals as hint, idx (hint)}
    {#if idx == 0 || hint != vpterm.val.trim()}
      <button
        class="hint"
        class:_base={hint == vpterm.b_val}
        class:_priv={hint == vpterm.u_val}
        data-kbd={v_kbd[idx]}
        on:click={() => (vpterm.val = hint)}>{hint}</button>
    {/if}
  {/each}

  <div class="right">
    {#each tag_hints as tag, idx (tag)}
      {#if tag != vpterm.ptag}
        <button
          class="hint _ptag"
          class:_base={tag == ptag_base}
          class:_priv={tag == ptag_priv}
          data-kbd={p_kbd[idx]}
          on:click={() => (vpterm.ptag = tag)}>{ptnames[tag]}</button>
      {/if}
    {/each}
  </div>
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex($gap: 0.125rem);
    @include ftsize(sm);
  }

  .right {
    margin-left: auto;
    @include flex();
    max-width: 30%;
  }

  // prettier-ignore
  .hint {
    cursor: pointer;
    padding: 0.25rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null);

    &._ptag {

      font-size: rem(13px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }
  }
</style>
