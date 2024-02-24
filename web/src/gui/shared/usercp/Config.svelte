<script context="module" lang="ts">
  import type { Writable } from 'svelte/store'

  const ftsizes = ['Rất nhỏ', 'Nhỏ vừa', 'Cỡ chuẩn', 'To vừa', 'Rất to']
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = ['Roboto', 'Merriweather', 'Nunito Sans', 'Lora', 'Roboto Slab']

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
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { config as data } from '$lib/stores'
  export let _user: Writable<App.CurrentUser>
</script>

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
    <button class="m-btn _sm" on:click={() => ($data.rfsize -= 1)} disabled={$data.rfsize == 1}>
      <SIcon name="minus" />
    </button>
    <field-value>{ftsizes[$data.rfsize - 1]}</field-value>
    <button class="m-btn _sm" on:click={() => ($data.rfsize += 1)} disabled={$data.rfsize == 5}>
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
    <button class="m-btn _sm" on:click={() => ($data.textlh -= 10)} disabled={$data.textlh <= 130}>
      <SIcon name="minus" />
    </button>
    <field-value>{$data.textlh}%</field-value>
    <button class="m-btn _sm" on:click={() => ($data.textlh += 10)} disabled={$data.textlh >= 180}>
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
  <label class="switch" data-tip="Tự động thanh toán vcoin cho các chương cần thiết mở khóa">
    <input type="checkbox" bind:checked={$data.auto_u} />
    <span class="switch-label">Tự động mở khóa chương bằng vcoin:</span>
  </label>
</div>

<style lang="scss">
  .config {
    @include flex-cy($gap: 0.5rem);
    margin-bottom: 0.75rem;
  }

  .config-hint {
    padding: 0 1rem;
    margin-top: 1rem;
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
  }
</style>
