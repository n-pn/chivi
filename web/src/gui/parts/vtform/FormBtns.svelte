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

  const button_styles = [
    '_default', // primary + plock 0
    '_warning', // primary + plock 1
    '_harmful', // primary + plock 2
    '_success', // regular + plock 1
    '_primary', // regular + plock 1
    '_teal', // regular + plock 2
  ]
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
  $: btn_style = button_styles[tform.local ? tform.plock : tform.plock + 3]
</script>

<button-group class="opts">
  <button
    type="button"
    class="m-btn _lg dict {tform.local ? 'local' : 'world'}"
    data-kbd="o"
    use:tooltip={dict_choice.desc}
    data-anchor=".vtform"
    on:click={() => (tform.local = !tform.local)}>
    <SIcon name={dict_choice.icon} />
  </button>

  <button
    type="button"
    class="m-btn _lg lock _{tform.plock}"
    data-kbd="p"
    use:tooltip={'Đổi chế độ khóa từ'}
    data-anchor=".vtform"
    on:click={change_plock}
    disabled={privi <= tform.init.plock + min_privi}>
    <SIcon name="plock-{tform.plock}" iset="icons" />
  </button>
</button-group>

<button
  class="m-btn _lg _fill {btn_style} _send"
  data-kbd="↵"
  type="submit"
  disabled={privi < tform.req_privi}>
  <span class="text">{tform.vstr ? 'Lưu' : 'Xoá'}</span>
  <SIcon name="privi-{tform.req_privi}" iset="icons" />
</button>

<style lang="scss">
  button-group {
    button:not(:last-child) {
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
    }
    button + button {
      margin-left: -1px;
      border-top-left-radius: 0;
      border-bottom-left-radius: 0;
    }
  }

  .opts {
    display: inline-flex;
    // align-items: center;
    margin-left: auto;
    // padding-left: 0.25rem;
    // gap: 0.5rem;
    // padding: 0 0.5rem;get
    // margin-left: 0.5rem;

    button {
      width: 2rem;
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
