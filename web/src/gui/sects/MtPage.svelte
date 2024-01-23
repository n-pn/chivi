<script context="module" lang="ts">
  import { config, vdict, zfrom } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MtData from '$lib/mt_data'

  import Mtmenu, { ctrl as mtmenu } from './MtPage/Mtmenu.svelte'

  import Zhline from './MtPage/Zhline.svelte'
  import Cvline, { show_txt } from './MtPage/Cvline.svelte'

  import LineEdit from './MtPage/LineEdit.svelte'

  import { rel_time } from '$utils/time_utils'
  import { beforeNavigate } from '$app/navigation'
</script>

<script lang="ts">
  import { browser } from '$app/environment'

  export let ztext: string = ''
  export let cvmtl: string = ''

  export let mtime: number = 0
  export let wn_id: number = 0

  export let do_fixraw = async (_n: number, _s: string, _s2: string) => ''
  export let on_change = () => render_v1(ztext)

  let article = null

  let l_hover = 0
  let l_focus = 0

  let zlines = []
  let datav1 = []
  let datav2 = []

  let tspan = 0
  let dsize = 0

  let fix_raw = false

  beforeNavigate(() => {
    mtmenu.hide()
    l_focus = 0
  })

  $: [datav1, tspan, dsize, dname] = MtData.parse_cvmtl(cvmtl)
  $: zlines = ztext ? ztext.split('\n') : []

  // $: if (browser && ztext && $config.render != 3) render_v2(ztext)

  async function render_v1(body: string, cv_title = 'first') {
    const url = `/_m1/qtran/cv_chap?wn_id=${wn_id}&cv_title=${cv_title}`
    const res = await fetch(url, { method: 'POST', body })

    if (!res.ok) return
    const data = MtData.parse_cvmtl(await res.text())

    datav1 = data[0]
    tspan = data[1]
    dsize = data[2]
    dname = data[3]
  }

  const on_fixraw = async (line_no: number, orig: string, edit: string) => {
    const message = await do_fixraw(line_no, orig, edit)

    if (message) {
      alert(message)
      return
    }

    const cv_title = line_no == 0
    const url = `/_m1/qtran/cv_chap?wn_id=${wn_id}&cv_title=${cv_title}`

    const res = await fetch(url, { method: 'POST', body: edit })
    datav1[line_no] = MtData.parse_cvmtl(await res.text())[0][0]
  }
</script>

<article
  class="article island reader"
  style:--textlh="{$config.textlh}%"
  bind:this={article}>
  <header>
    <span class="stats" data-tip="Phiên bản máy dịch">
      <span class="stats-label">Máy dịch:</span>
      <SIcon name="versions" />
      <span class="stats-value">V1</span>
    </span>

    <span class="stats" data-tip="Thời gian chạy máy dịch">
      <span class="stats-label">Thời gian dịch:</span>
      <SIcon name="clock" />
      <span class="stats-value">{tspan}ms</span>
    </span>
    <span class="stats _dname" data-tip="Từ điển bộ truyện">
      <span class="stats-label">Từ điển riêng:</span>
      <SIcon name="package" />
      <a href="/mt/dicts/{dname || $vdict.dslug}" class="stats-value _link"
        >{dsize} từ</a>
    </span>

    <div class="header-right">
      {#if mtime && mtime > 0}
        <span class="stats" data-tip="Thời gian lưu văn bản gốc">
          <SIcon name="file-download" />
          <span class="stats-value"
            >{rel_time(mtime).replace(' trước', ' tr.')}</span>
        </span>
      {/if}

      <span class="stats" data-tip="Số ký tự tiếng Trung">
        <SIcon name="file-analytics" />
        <span class="stats-value">{ztext.length}</span>
        <span class="stats-label"> chữ</span>
      </span>
    </div>
  </header>

  <section>
    {#each zlines as input, index (index)}
      {@const elem = index > 0 || $$props.no_title ? 'p' : 'h1'}
      {@const mtlv1 = datav1[index]}
      {@const plain = show_txt(
        $config.r_mode,
        zlines.length - 1,
        index,
        l_hover,
        l_focus
      )}
      <svelte:element
        this={elem}
        id="L{index}"
        class="cdata"
        class:focus={index == l_focus}
        on:mouseenter={() => (l_hover = index)}
        role="tooltip">
        {#if $config.show_z}<Zhline ztext={input} {plain} />{/if}

        {#if mtlv1}
          <Cvline input={mtlv1} {plain} />
        {/if}
      </svelte:element>
    {/each}
  </section>

  {#if $config.r_mode != 1}
    <Mtmenu
      {article}
      lines={zlines}
      bind:l_focus
      bind:fix_raw
      {l_hover}
      {on_change} />
  {/if}

  {#if fix_raw}
    <LineEdit
      bind:rawtxt={zlines[l_focus]}
      bind:fix_raw
      {on_fixraw}
      lineid={l_focus}
      caret={$zfrom}
      vd_id={$vdict.vd_id} />
  {/if}

  <slot name="footer" />
</article>

<div hidden>
  <button data-kbd="z" on:click={() => config.set_r_mode(1)}>Z</button>
  <button data-kbd="d" on:click={() => config.set_r_mode(2)}>D</button>
  <button data-kbd="a" on:click={() => config.toggle('show_z')}>A</button>
</div>

<style lang="scss">
  .article {
    position: relative;
    min-height: 30vh;

    // margin: 0;
    padding: 0;
    padding-bottom: 0.75rem;

    @include fgcolor(secd);
    @include bgcolor(tert);

    :global(.tm-warm) & {
      background-color: #fffbeb;
    }

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
    }

    & > header,
    & .cdata {
      @include padding-x(var(--gutter));

      @include bp-min(tl) {
        @include padding-x(2rem);
      }
    }
  }

  header {
    display: flex;
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    // @include fgcolor(secd);
    @include border(--bd-soft, $loc: bottom);
  }

  .header-right {
    display: flex;
    margin-left: auto;
    padding-left: 0.25rem;
  }

  .stats {
    display: inline-flex;
    align-items: center;

    @include ftsize(sm);
    @include fgcolor(mute);

    & + &:before {
      content: ' ';
      margin: 0 0.25rem;
    }
  }

  .stats-label {
    display: none;
    // font-style: italic;

    @include bp-min(ts) {
      display: inline-block;

      .stats-value + & {
        margin-left: 0.125rem;
      }
      & + :global(svg) {
        display: none;
      }
    }
  }

  .stats-value {
    font-style: normal;
    margin-left: 0.125rem;
    // font-weight: 500;
    @include fgcolor(tert);

    &._link {
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
