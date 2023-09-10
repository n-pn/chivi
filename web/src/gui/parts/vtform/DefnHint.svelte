<script lang="ts">
  import { gtran, btran, deepl } from '$utils/qtran_utils'

  import { hint, type CvtermForm } from './_shared'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let form: CvtermForm
  export let hanviet: string
  export let val_hints: string[]

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

  const trigger_show_more = (value: number) => {
    show_more = value == show_more ? 0 : value
  }

  var show_more = 0
  $: if (form) show_more = 0

  async function run_gtran(tab = 0) {
    form.val = '...'
    form.val = await gtran(form.key, tab)
  }

  async function run_btran(tab = 0) {
    form.val = '...'
    form.val = await btran(form.key, tab, true)
  }

  async function run_deepl(tab = 0) {
    form.val = '...'
    form.val = await deepl(form.key, tab, false)
  }

  $: init_val = form.init.val
</script>

<div class="wrap">
  <div class="hints">
    <div class="left">
      <button
        class="hint"
        class:_prev={hanviet == init_val}
        data-kbd="q"
        on:click={() => (form.val = hanviet)}>{hanviet}</button>

      {#each hints.slice(0, limit) as val, idx}
        <button
          class="hint"
          class:_prev={val == init_val}
          on:click={() => (form.val = val)}>{val}</button>
      {/each}

      {#if hints.length > limit}
        <button
          class="hint _icon"
          on:click={() => trigger_show_more(1)}
          use:hint={'Ẩn/hiện các gợi ý nghĩa cụm từ'}
          ><SIcon name={show_more == 1 ? 'minus' : 'plus'} /></button>
      {/if}
    </div>

    <span class="right">
      <button
        class="hint lang-btn"
        data-kbd="5"
        on:click={() => run_gtran(0)}
        use:hint={'Dịch bằng Google từ Trung sang Việt'}>
        <span class="lang-ico">
          <SIcon name="brand-google" />
          <span class="lang">🇻🇳</span>
        </span>
      </button>

      <button
        class="hint lang-btn"
        data-kbd="6"
        on:click={() => run_btran(0)}
        use:hint={'Dịch bằng Bing từ Trung sang Việt'}>
        <span class="lang-ico">
          <SIcon name="brand-bing" />
          <span class="lang">🇻🇳</span>
        </span>
      </button>

      <button
        class="hint lang-btn"
        data-kbd="7"
        on:click={() => run_deepl(0)}
        use:hint={'Dịch bằng DeepL từ Trung sang Anh'}>
        <span class="lang-ico">
          <img src="/icons/deepl.svg" alt="deepl" />
          <span class="lang">🇺🇸</span>
        </span>
      </button>

      <button
        class="hint _icon"
        data-kbd="t"
        on:click={() => trigger_show_more(2)}
        use:hint={'Xem các lựa chọn dịch tự động khác'}
        ><SIcon name={show_more == 2 ? 'minus' : 'plus'} /></button>
    </span>
  </div>

  {#if show_more == 1}
    <div class="extra">
      {#each hints.slice(limit) as val}
        <button
          class="hint"
          class:_prev={val == init_val}
          on:click={() => (form.val = val)}>{val}</button>
      {/each}
    </div>
  {/if}

  {#if show_more == 2}
    <div class="extra _right">
      <button
        class="hint lang-btn"
        on:click={() => run_gtran(1)}
        use:hint={'Dịch bằng Google từ Trung sang Anh'}>
        <span class="lang-ico">
          <SIcon name="brand-google" />
          <span class="lang">🇺🇸</span>
        </span>
        <span class="lbl">Anh</span>
      </button>

      <button
        class="hint lang-btn"
        on:click={() => run_gtran(2)}
        use:hint={'Dịch bằng Google từ Nhật sang Việt'}>
        <span class="lang-ico">
          <SIcon name="brand-google" />
          <span class="lang">🇯🇵</span>
        </span>
        <span class="lbl">Nhật</span>
      </button>

      <button
        class="hint lang-btn"
        on:click={() => run_btran(1)}
        use:hint={'Dịch bằng Bing từ Trung sang Anh'}>
        <span class="lang-ico">
          <SIcon name="brand-bing" />
          <span class="lang">🇺🇸</span>
        </span>
        <span class="lbl">Anh</span>
      </button>

      <button
        class="hint lang-btn"
        on:click={() => run_btran(2)}
        use:hint={'Dịch bằng Bing từ Nhật sang Việt'}>
        <span class="lang-ico">
          <SIcon name="brand-bing" />
          <span class="lang">🇯🇵</span>
        </span>
        <span class="lbl">Nhật</span>
      </button>

      <button
        class="hint lang-btn"
        on:click={() => run_deepl(1)}
        use:hint={'Dịch bằng DeepL từ Nhật sang Anh'}>
        <span class="lang-ico">
          <img src="/icons/deepl.svg" alt="deepl" />
          <span class="lang">🇯🇵</span>
        </span>
        <span class="lbl">Nhật</span>
      </button>
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

    justify-content: space-between;
    padding: 0.25rem 0.5rem;
    height: 2rem;
  }

  .left,
  .right {
    @include flex();
  }

  .left {
    flex-shrink: 1;
    @include clamp($width: null);
  }

  .extra {
    @include flex();
    @include ftsize(xs);

    padding: 0.125rem 0.5rem;

    height: auto;
    flex-wrap: wrap;
    position: absolute;
    bottom: 1.75rem;
    left: 0;
    right: 0;

    @include border;
    border-bottom-color: var(--bd-soft);

    @include bdradi($loc: top);
    @include bgcolor(secd);

    &._right {
      justify-content: right;
    }
  }

  .hint {
    // display: inline-flex;
    // align-items: center;

    padding: 0 0.2rem;
    line-height: 1.5rem;

    background: none;
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
      margin-left: -0.125rem;
      margin-right: -0.125rem;
      @include fgcolor(mute);
    }
  }

  .lang-ico {
    display: inline-block;
    position: relative;
    padding-right: 0.375rem;
    transform: translateY(-0.125rem);

    > span {
      display: inline-block;
      position: absolute;
      font-size: rem(8px);
      line-height: 1em;

      right: 0rem;
      bottom: 0.25rem;
      opacity: 0.6;
    }
  }

  .lbl {
    font-weight: 500;
  }

  img {
    display: inline-block;
    width: rem(14px);
    height: rem(18px);
  }

  // .lang {
  //   position: absolute;
  //   display: inline-block;

  //   bottom: 0.25rem;
  //   right: -0.125rem;
  //   line-height: 0.75rem;
  //   width: 0.75rem;
  //   text-align: center;
  //   font-size: 9px;
  //   font-weight: 500;
  //   text-transform: uppercase;
  //   border-radius: 0.125rem;
  //   // @include border();
  //   @include linesd(--bd-main, $inset: false);
  // }
</style>
