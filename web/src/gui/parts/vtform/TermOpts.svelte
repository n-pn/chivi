<script context="module" lang="ts">
  const dict_choices = {
    t: {
      desc: 'Áp dụng nghĩa từ cho bộ truyện hiện tại',
      icon: 'book',
    },

    f: {
      desc: 'Áp dụng nghĩa từ cho tất cả các bộ truyện',
      icon: 'world',
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { tooltip } from '$lib/actions'
  import type { Vtform } from '$lib/models/viterm'

  // import { type CvtermForm, hint, req_privi } from './_shared'

  export let tform: Vtform
  export let privi: number

  $: dict_choice = dict_choices[tform.local ? 't' : 'f']

  function change_plock() {
    if (tform.plock == 2) {
      tform.plock = 0
    } else {
      tform.plock = tform.plock + 1
    }
  }

  $: min_privi = tform.local ? 0 : 1
  $: max_plock = tform.init.plock + min_privi
</script>

<div class="opts">
  <button
    class="dict {tform.local ? 'local' : 'world'}"
    use:tooltip={dict_choice.desc}
    data-anchor=".vtform"
    on:click={() => (tform.local = !tform.local)}>
    <SIcon name={dict_choice.icon} />
  </button>

  <button
    class="lock _{tform.plock}"
    use:tooltip={'Đổi chế độ khóa từ'}
    data-anchor=".vtform"
    on:click={change_plock}
    disabled={privi <= tform.init.plock + min_privi}>
    <SIcon name="plock-{tform.plock}" iset="icons" />
  </button>
</div>

<style lang="scss">
  .opts {
    display: inline-flex;
    align-items: center;
    margin-left: auto;
    padding-left: 0.25rem;
    // gap: 0.5rem;
    // padding: 0 0.5rem;get
    // margin-left: 0.5rem;
  }

  button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    line-height: 2rem;

    background: inherit;
    padding: 0;
    @include ftsize(lg);
    @include fgcolor(secd);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .dict {
    &.local {
      @include fgcolor(warning);
    }

    &.world {
      @include fgcolor(primary);
    }
  }

  .lock {
    &._0 {
      @include fgcolor(green);
    }

    &._1 {
      @include fgcolor(primary);
    }

    &._2 {
      @include fgcolor(red);
    }
  }

  // .label {
  //   cursor: pointer;
  //   line-height: 1.25rem;
  //   // font-weight: 500;

  //   @include bps(font-size, rem(12px), $pm: rem(13px), $pl: rem(14px));

  //   @include fgcolor(tert);

  //   &._active {
  //     @include fgcolor(secd);
  //   }
  // }

  // .choices {
  //   display: flex;
  //   gap: 0.5rem;
  // }

  // ._hide {
  //   @include bps(display, none, $pl: initial);
  // }

  // ._right {
  //   margin-left: auto;
  // }
</style>
