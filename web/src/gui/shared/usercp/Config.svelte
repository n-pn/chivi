<script context="module" lang="ts">
  import type { Writable } from 'svelte/store'
  import { get_dmy } from '$utils/time_utils'

  const hour_span = 3600
  const day_span = 3600 * 24
  const month_span = day_span * 30

  function avail_until(time: number) {
    const diff = time - new Date().getTime() / 1000

    if (diff < hour_span) return '< 1 tiếng'
    if (diff < day_span) return `${round(diff, hour_span)} tiếng`
    if (diff < month_span) return `${round(diff, day_span)} ngày`

    return get_dmy(new Date(time * 1000))
  }

  function round(input: number, unit: number) {
    return input <= unit ? 1 : Math.floor(input / unit)
  }

  const ftsizes = ['Rất nhỏ', 'Nhỏ vừa', 'Cỡ chuẩn', 'To vừa', 'Rất to']
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = [
    'Roboto',
    'Merriweather',
    'Nunito Sans',
    'Lora',
    'Roboto Slab',
  ]

  // const textlhs = [150, 150, 150, 150]
  const r_modes = [
    ['Thường', 0],
    ['Zen', 1],
    ['Dev', 2],
  ]

  const rmode_descs = [
    'Bấm vào dòng sẽ hiện lên chi tiết dòng',
    'Bấm vào dòng không hiện cửa sổ chi tiết',
    'Xem các cụm từ nếu dùng chế độ dịch máy',
  ]
</script>

<script lang="ts">
  import RdchapList from '$gui/parts/rdmemo/RdchapList.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { config as data } from '$lib/stores'
  export let _user: Writable<App.CurrentUser>

  async function load_rdmemos(): Promise<Array<CV.Rdmemo>> {
    const url = `/_rd/rdmemos?rtype=rdlog&lm=4`
    const res = await fetch(url)

    if (!res.ok) {
      alert(await res.text())
      return []
    }

    const data = await res.json()
    return data.items
  }

  $: privi = $_user.privi || -1
</script>

<section class="infos">
  <div class="info">
    <div>
      <span class="lbl">Quyền hạn:</span>
      <SIcon name="privi-{privi}" iset="icons" />
    </div>
    {#if privi > 3}
      <a class="m-btn _xs _harmful" href="/su" target="_blank">
        <span>Quản lý</span>
      </a>
    {:else if privi < 0}
      <a class="m-btn _xs _primary" href="/me/privi">
        <span>Nâng cấp</span>
      </a>
    {:else}
      <div>
        <span class="lbl">Hết hạn:</span>
        <strong>{avail_until($_user.until)}</strong>
      </div>

      <a class="m-btn _xs _primary" href="/me/privi">
        <span>Gia hạn</span>
      </a>
    {/if}
  </div>

  <div class="info">
    <div>
      <span class="lbl">Số Vcoin:</span>
      <strong>{Math.round($_user.vcoin * 1000) / 1000}</strong>
      <SIcon iset="icons" name="vcoin" />
    </div>

    <a href="/me/vcoin" class="m-btn _xs _primary" target="_blank">
      <span>Trao đổi</span>
    </a>
  </div>
</section>

<hr />

<section class="links">
  <a class="m-btn _xs" href="/me">
    <SIcon name="user" />
    <span>Cá nhân</span>
  </a>

  <a class="m-btn _xs _primary" href="/me/books">
    <SIcon name="books" />
    <span>Tủ truyện</span>
  </a>

  <a class="m-btn _xs _warning" href="/me/earned">
    <SIcon name="coin" />
    <span class="-txt">Thu phí</span>
  </a>
</section>

<hr />
<h4>
  <span>Chương tiết vừa đọc</span>
  <a href="/me/rdlog"><em>Xem tất cả</em></a>
</h4>

<div class="chaps">
  {#await load_rdmemos()}
    <div class="d-empty-sm">Đang tải lịch sử đọc truyện.</div>
  {:then items}
    <RdchapList {items} />
  {/await}
</div>

<hr />
<h4>Giao diện hệ thống</h4>
<div class="config">
  <span class="label">Màu nền:</span>
  <field-input>
    {#each wthemes as value}
      <label class="wtheme _{value}" class:_active={value == $data.wtheme}>
        <input type="radio" name="wtheme" {value} bind:group={$data.wtheme} />
      </label>
    {/each}
  </field-input>
</div>

<div class="config">
  <span class="label">Font chữ:</span>
  <field-input>
    <select class="m-input" name="wfface" bind:value={$data.wfface}>
      {#each ftfaces as value, index}
        <option value={index + 1}>{value}</option>
      {/each}
    </select>
  </field-input>
</div>

<hr />

<h4>Giao diện đọc truyện</h4>
<div class="config">
  <span class="label">Cỡ chữ:</span>
  <field-input>
    <button
      class="m-btn _sm"
      on:click={() => ($data.rfsize -= 1)}
      disabled={$data.rfsize == 1}>
      <SIcon name="minus" />
    </button>
    <field-value>{ftsizes[$data.rfsize - 1]}</field-value>
    <button
      class="m-btn _sm"
      on:click={() => ($data.rfsize += 1)}
      disabled={$data.rfsize == 5}>
      <SIcon name="plus" />
    </button>
  </field-input>
</div>

<div class="config">
  <span class="label">Font chữ:</span>
  <field-input>
    <select class="m-input" name="rfface" bind:value={$data.rfface}>
      {#each ftfaces as value, index}
        <option value={index + 1}>{value}</option>
      {/each}
    </select>
  </field-input>
</div>

<div class="config">
  <span class="label">Giãn dòng:</span>
  <field-input>
    <button
      class="m-btn _sm"
      on:click={() => ($data.textlh -= 10)}
      disabled={$data.textlh <= 130}>
      <SIcon name="minus" />
    </button>
    <field-value>{$data.textlh}%</field-value>
    <button
      class="m-btn _sm"
      on:click={() => ($data.textlh += 10)}
      disabled={$data.textlh >= 180}>
      <SIcon name="plus" />
    </button>
  </field-input>
</div>

<hr />

<h4>Cài đặt đọc truyện</h4>

<div class="config">
  <span class="label _sm">Chế độ đọc:</span>
  <field-input>
    {#each r_modes as [label, value]}
      <label
        class:_active={value == $data.r_mode}
        data-tip={rmode_descs[value]}
        data-tip-loc="bottom"
        data-tip-pos={value == 2 ? 'right' : 'middle'}>
        <input type="radio" name="r_mode" {value} bind:group={$data.r_mode} />
        <span>{label}</span>
      </label>
    {/each}
  </field-input>
</div>

<div class="config">
  <label class="switch">
    <input type="checkbox" bind:checked={$data.show_z} />
    <span class="switch-label">Hiển thị song song tiếng Trung:</span>
  </label>
</div>

<div class="config">
  <label
    class="switch"
    data-tip="Tự động thanh toán vcoin cho các chương cần thiết mở khóa">
    <input type="checkbox" bind:checked={$data.auto_u} />
    <span class="switch-label">Tự động mở khóa chương bằng vcoin:</span>
  </label>
</div>

<style lang="scss">
  .info {
    @include flex-cy;

    & + & {
      margin-top: 0.25rem;
    }

    > div {
      margin-right: 0.5rem;
      @include ftsize(sm);
      @include fgcolor(secd);
    }

    .lbl {
      @include fgcolor(tert);
    }

    > button,
    a {
      margin-left: auto;
    }

    :global(svg) {
      height: 1rem;
      width: 1rem;
      margin-bottom: 0.125rem;
      margin-right: 0.075rem;
    }
  }

  .links {
    @include flex-ca($gap: 0.5rem);

    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }
  }

  .config {
    @include flex-cy($gap: 0.5rem);
    margin-bottom: 0.75rem;
  }

  .config-hint {
    padding: 0 1rem;
    margin-top: 1rem;
  }

  hr {
    display: block;
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
    @include border($loc: top);
  }

  .label {
    display: inline-block;
    min-width: 33%;
    // @include ftsize(sm);
    font-weight: 500;

    &._sm {
      width: 25%;
    }
  }

  field-input {
    flex: 1;
    margin-left: auto;
    @include flex-cy($gap: 0.5rem);
  }

  field-value {
    flex: 1;
    text-align: center;
  }

  .m-btn {
    background: inherit;
  }

  select {
    display: block;
    width: 100%;
    line-height: 2rem;
    padding: 0.5rem;
  }

  .wtheme {
    text-transform: capitalize;
    cursor: pointer;
    display: inline-flex;

    position: relative;

    width: 2rem;
    height: 2rem;

    border-radius: 1rem;
    @include linesd(--bd-main, $inset: false);

    &:hover {
      --ringbg: var(--bg-secd);
      @include ringsd(primary, 5, $offset: 3px, $ndef: false);
    }

    > input {
      display: none;
    }

    &._light {
      --check: #{color(primary, 6)};
      @include bgcolor(neutral, 0);
    }

    &._warm {
      --check: #{color(primary, 6)};
      @include bgcolor(orange, 1);
    }

    &._dark {
      --check: #{color(primary, 4)};
      @include bgcolor(primary, 9);
    }

    &._oled {
      --check: #{color(primary, 4)};
      background: #000;
    }

    &._active:after {
      position: absolute;
      display: inline-block;
      content: '';
      transform: rotate(45deg);
      height: 1rem;
      width: 0.5rem;
      top: 0.375rem;
      left: 0.75rem;

      @include border(--check, $width: 3px, $loc: bottom-right);
    }

    & + & {
      margin-left: 0.25rem;
    }
  }

  .switch {
    display: block;
    width: 100%;
    // @include flex($center: vert);

    // prettier-ignore
    > input { display: none; }
  }

  .switch-label {
    display: block;
    position: relative;
    font-weight: 500;
    $size: 1.5rem;

    &:before {
      display: inline-block;
      content: '';
      position: absolute;
      right: 0;
      top: 0;
      @include bgcolor(neutral, 1);
      @include linesd(neutral, 2, $inset: true);

      @include tm-dark {
        @include bgcolor(neutral, 7);
        @include linesd(neutral, 6, $inset: true, $ndef: false);
      }

      height: $size;
      border-radius: 1rem;
      width: $size * 2;

      cursor: pointer;
      overflow: hidden;
    }

    &:after {
      top: 0;
      right: 0;
      border-radius: 20px;
      content: ' ';
      display: block;
      height: $size;
      width: $size;
      position: absolute;

      transition: all 0.1s linear;
      transform: translateX(-100%);

      @include bgcolor(white);
      @include linesd(neutral, 2, $inset: false);

      @include tm-dark {
        @include bgcolor(neutral, 2);
        @include linesd(neutral, 8, $inset: false, $ndef: false);
      }
    }

    input:checked + & {
      &:before {
        @include bgcolor(primary, 5);
        @include linesd(primary, 5, $inset: true, $ndef: false);
      }

      &:after {
        transform: translateX(0);
        @include linesd(primary, 5, $inset: false, $ndef: false);
      }
    }
  }

  label {
    cursor: pointer;
  }

  h4 {
    display: flex;
    font-weight: 500;
    margin-bottom: 0.5rem;
    @include fgcolor(tert);

    > a {
      margin-left: auto;
      color: inherit;
      font-size: smaller;
      font-weight: 400;
      &:hover {
        @include fgcolor(primary, 4);
      }
    }
  }
</style>
