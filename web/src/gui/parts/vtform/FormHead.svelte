<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { render_vdata } from '$lib/mt_data_2'

  import { ctrl, data } from '$lib/stores/vtform_stores'

  export let ztext = ''
  export let hviet = ''
  export let vtext = ''

  let from = $data.from
  let upto = $data.upto

  $: input = tr
  $: update_input(from, upto)

  const update_input = (from, upto) => {
    output = text.substring(from, upto)
    prefix = text.substring(from - 10, from)
    suffix = text.substring(upto, upto + 10)
  }

  function change_focus(index: number) {
    if (index != $data.from && index < $data.upto) $data.from = index
    if (index >= $data.from) $data.upto = index + 1
  }

  function shift_lower(value = 0) {
    value += $data.from
    if (value < 0 || value >= $data.text.length) return

    $data.from = value
    if ($data.upto <= value) $data.upto = value + 1
  }

  function shift_upper(value = 0) {
    value += $data.upto
    if (value < 1 || value > $data.text.length) return

    $data.upto = value
    if ($data.from >= value) $data.from = value - 1
  }
</script>

<header class="head">
  <button class="m-btn _text">
    <SIcon name="compass" />
  </button>

  <div class="text">
    <button
      class="btn _left _hide"
      data-kbd="←"
      disabled={$data.from == 0}
      on:click={() => shift_lower(-1)}>
      <SIcon name="chevron-left" />
    </button>

    <button
      class="btn _left"
      data-kbd="⇧←"
      disabled={$data.from == $data.text.length - 1}
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
              on:click={() => change_focus($data.from + idx)}>{chr}</button>
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
      disabled={$data.upto == 1}
      on:click={(e) => shift_upper(-1)}>
      <SIcon name="chevron-left" />
    </button>

    <button
      class="btn _right _hide"
      data-kbd="→"
      disabled={$data.upto == $data.text.length}
      on:click={(e) => shift_upper(1)}>
      <SIcon name="chevron-right" />
    </button>
  </div>

  <button type="button" class="m-btn _text" data-kbd="esc" on:click={ctrl.hide}>
    <SIcon name="x" />
  </button>
</header>

<section class="tree">
  {render_vdata($data.tree, 2)}
</section>

<style lang="scss">
  $height: 2.25rem;

  .text {
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
