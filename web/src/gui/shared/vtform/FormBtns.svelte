<script context="module" lang="ts">
  const dict_choices = [
    ['user', 'Thêm vào từ điển cá nhân của bạn'],
    ['book', 'Thêm vào từ điển riêng bộ hiện tại'],
    ['world', 'Thêm vào từ điển chung tất cả các bộ'],
  ]
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { Viform } from './zvdefn_form'

  // import { type CvtermForm, hint, req_privi } from './_shared'

  export let tform: Viform
  export let uname: string
  export let privi: number

  export let show_dfn = false
  // export let show_log = false

  $: btn_style = ['_harmful', '_success', '_primary'][tform.state]
</script>

<section class="actions">
  <button
    type="button"
    class="m-btn _primary"
    on:click={() => (show_dfn = !show_dfn)}
    data-umami-event="vtform-lookup">
    <SIcon name="compass" />
    <span class="-txt u-show-pl">Tra nghĩa</span>
  </button>

  <button-group class="u-right">
    {#each dict_choices as [dicon, brief], d_no}
      <button
        type="button"
        class="m-btn dict _{d_no}"
        class:_active={d_no == tform.d_no}
        data-kbd="o"
        data-tip={brief}
        on:click={() => (tform.d_no = d_no)}>
        <SIcon name={dicon} />
      </button>
    {/each}
  </button-group>

  <button-group class:_lock={tform.lock}>
    <button
      type="button"
      class="m-btn _lg _fill {btn_style} lock"
      data-kbd="p"
      data-tip="Đổi chế độ khóa từ"
      on:click={() => (tform.lock = !tform.lock)}
      disabled={privi <= tform.min_privi}>
      <SIcon name="plock-{tform.plock}" iset="icons" />
    </button>
    <button
      class="m-btn _lg _fill {btn_style}"
      data-kbd="↵"
      type="submit"
      disabled={privi < tform.req_privi}
      data-umami-event="upsert-viterm"
      data-umami-event-uname={uname}
      data-umami-event-privi={privi}>
      <span class="text">{tform.state ? 'Lưu' : 'Xóa'}</span>
      <!-- <SIcon name="privi-{tform.req_privi + 1}" iset="icons" /> -->
    </button>
  </button-group>
</section>

<style lang="scss">
  .actions {
    @include flex-ca;
    gap: 0.75rem;
    padding-top: 0.75rem;
  }

  button {
    padding-left: 0.5rem;
    padding-right: 0.5rem;
  }

  button-group {
    display: inline-flex;

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

  .dict._active._0 {
    @include fgcolor(private);
  }

  .dict._active._1 {
    @include fgcolor(warning);
  }

  .dict._active._2 {
    @include fgcolor(primary);
  }

  .lock :global(svg) {
    width: 1.5rem;
  }

  button-group._lock > button {
    @include fgcolor(yellow, 4);
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
