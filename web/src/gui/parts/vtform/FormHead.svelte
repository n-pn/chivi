<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { ctrl, data } from '$lib/stores/vtform_stores'

  export let output = ''

  let prefix = ''
  let suffix = ''

  $: update_input($data)

  const update_input = ({ ztext, zfrom, zupto }) => {
    output = ztext.substring(zfrom, zupto)
    prefix = ztext.substring(zfrom - 10, zfrom)
    suffix = ztext.substring(zupto, zupto + 10)
  }

  function change_focus(index: number) {
    if (index != $data.zfrom && index < $data.zupto) $data.zfrom = index
    if (index >= $data.zfrom) $data.zupto = index + 1
  }

  function shift_lower(value = 0) {
    value += $data.zfrom
    if (value < 0 || value >= $data.ztext.length) return

    $data.zfrom = value
    if ($data.zupto <= value) $data.zupto = value + 1
  }

  function shift_upper(value = 0) {
    value += $data.zupto
    if (value < 1 || value > $data.ztext.length) return

    $data.zupto = value
    if ($data.zfrom >= value) $data.zfrom = value - 1
  }
</script>

<div class="ztext">
  <button
    class="btn _left _hide"
    data-kbd="←"
    disabled={$data.zfrom == 0}
    on:click={() => shift_lower(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _left"
    data-kbd="⇧←"
    disabled={$data.zfrom == $data.ztext.length - 1}
    on:click={() => shift_lower(1)}>
    <SIcon name="chevron-right" />
  </button>

  <div class="key">
    <div class="key-txt">
      <div class="key-pre">
        {#each Array.from(prefix) as chr, idx}
          {@const offset = prefix.length - idx}
          <button class="key-btn" on:click={() => shift_lower(-offset)}
            >{chr}</button>
        {/each}
      </div>

      <div class="key-out">
        {#each output.slice(0, 6) as chr, idx}
          <button
            class="key-btn _out"
            on:click={() => change_focus($data.zfrom + idx)}>{chr}</button>
        {/each}
        {#if output.length > 6}
          <span class="trim">(+{output.length - 6})</span>
        {/if}
      </div>

      <div class="key-suf">
        {#each Array.from(suffix) as chr, idx}
          {@const offset = idx + 1}
          <button class="key-btn" on:click={() => shift_upper(offset)}
            >{chr}</button>
        {/each}
      </div>
    </div>
  </div>

  <button
    class="btn _right"
    data-kbd="⇧→"
    disabled={$data.zupto == 1}
    on:click={(e) => shift_upper(-1)}>
    <SIcon name="chevron-left" />
  </button>

  <button
    class="btn _right _hide"
    data-kbd="→"
    disabled={$data.zupto == $data.ztext.length}
    on:click={(e) => shift_upper(1)}>
    <SIcon name="chevron-right" />
  </button>
</div>

<style lang="scss">
  $height: 2.25rem;

  .ztext {
    display: flex;
    width: calc(100% - 4.5rem);
    height: $height;
    position: relative;
    background-color: inherit;
  }

  .key {
    flex-grow: 1;
    display: flex;
    justify-content: center;

    overflow: hidden;
    flex-wrap: nowrap;
    font-size: rem(20px);
    @include border(--bd-soft, $loc: left-right);
  }

  .key-txt {
    position: relative;
    max-width: 100%;
    line-height: $height;
    font-family: var(--font-sans);
  }

  .trim {
    @include fgcolor(tert);
    font-size: rem(16px);
  }

  .key-pre,
  .key-suf {
    display: block;
    position: absolute;
    top: 0;
    font-weight: 400;
    height: 100%;
    white-space: nowrap;
    @include fgcolor(mute);
  }

  .key-pre {
    right: 100%;
  }

  .key-suf {
    left: 100%;
  }

  .key-btn {
    display: inline-block;
    padding: 0;
    margin: 0;
    min-width: 0.5em;
    text-align: center;
    color: inherit;
    background: transparent;

    &._out {
      font-weight: 500;
      @include fgcolor(primary, 5);
    }
    // prettier-ignore
    // @include hover { @include fgcolor(primary, 5); }
  }

  .btn {
    background: transparent;
    padding: 0 0.5rem;
    margin: 0;
    line-height: 1em;
    max-width: 65vw;

    @include ftsize(lg);
    @include fgcolor(secd);

    &._left {
      @include border(--bd-soft, $loc: left);
    }

    &._right {
      @include border(--bd-soft, $loc: right);
    }

    &._hide {
      @include bps(display, none, $pl: inline-block);
    }

    &:hover {
      // @include bgcolor(tert);
      @include fgcolor(primary, 5);
    }

    &:disabled {
      cursor: pointer;
      @include fgcolor(neutral, 5);
      background: transparent;
    }
  }
</style>
