<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy, onMount } from 'svelte'
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let actived = false

  export let raw_txt = ''
  export let line_no = 0

  export let dname = 'combine'
  export let caret = 0

  export let on_changed = (_n: number, _s: string, _s2: string) => {}
  export let on_destroy = () => {}

  onDestroy(() => {
    on_destroy()
  })

  let hint_tabs = ['Bản dịch trước', 'Dịch máy', 'Hán Việt', 'Google', 'Bing']
  let hint_data = []
  let hint_atab = 0

  function save_change() {
    on_changed(line_no, raw_txt, '')
    alert('Todo!')
  }
</script>

<Dialog {actived} on_close={() => (actived = false)} class="chtran" _size="lg">
  <header slot="header">Dịch tay</header>

  <div class="body">
    <section class="rawtxt">
      <div class="label">Text gốc:</div>
      <textarea class="m-inp" disabled rows="10" value={raw_txt} />
    </section>

    <section class="hints">
      <div class="hint-tabs">
        <span class="label">Gợi ý dịch:</span>
        {#each hint_tabs as label, idx}
          <label>
            <input type="radio" bind:group={hint_atab} value={idx} />
            <span>{label}</span>
          </label>
        {/each}
      </div>

      <div class="hint-data">
        {hint_data[hint_atab]}
      </div>
    </section>
  </div>

  <footer>
    <button class="m-btn _primary _fill" on:click={save_change}>
      <span>Lưu thay đổi</span>
      <SIcon name="send" />
    </button>
  </footer>
</Dialog>

<style lang="scss">
  .raw_txt {
    position: relative;
    padding: 0;

    min-height: 4rem;
    max-height: 10rem;
    overflow-y: scroll;
    resize: vertical;
  }

  // .overlay,
  // .underlay {
  //   padding: 0.25rem 0.5rem;
  //   width: 100%;
  //   height: 100%;
  // }

  // .overlay {
  //   position: relative;
  //   color: transparent;
  //   caret-color: color(primary, 5);
  //   background: transparent;
  // }

  // .underlay {
  //   position: absolute;
  //   // top: 0;
  //   // left: 0;

  //   // bottom: 0;
  //   // right: 0;
  //   // user-select: none;

  //   :global(x-c.active) {
  //     font-weight: 500;
  //     @include fgcolor(primary, 5);
  //   }
  // }
  // div.m-input {
  //   display: flex;
  //   flex-wrap: wrap;
  // }

  .body {
    padding: 0.75rem;
    padding-top: 0.5rem;
  }

  // .suggest {
  //   display: flex;
  //   align-items: center;
  //   height: 1.5rem;
  //   margin-bottom: 0.25rem;
  // }

  // .suggests {
  //   margin-left: auto;
  // }

  // .suggest,
  // .preview {
  //   font-size: rem(15px);
  //   @include fgcolor(tert);
  // }

  // .no-suggest {
  //   font-style: italic;
  //   @include fgcolor(mute);
  // }

  footer {
    @include flex();
    padding-bottom: 0.75rem;
    gap: 0.75rem;
    justify-content: center;
  }

  // .suggest-btn {
  //   background: none;
  //   font-size: rem(14px);

  //   @include fgcolor(main);
  //   @include hover {
  //     @include fgcolor(primary, 5);
  //   }
  // }

  // .mute {
  //   @include fgcolor(mute);
  // }

  .label {
    font-weight: 500;
  }

  .preview {
    margin-top: 0.5rem;
  }

  // .hanviet,
  // .convert {
  //   @include border();
  //   @include bdradi();
  //   min-height: 5rem;
  //   padding: 0.25rem 0.75rem;
  //   margin-top: 0.25rem;
  //   line-height: 1.25rem;
  //   font-weight: 400;
  //   font-size: rem(14px);
  //   @include fgcolor(tert);
  //   @include bgcolor(tert);
  // }
</style>
