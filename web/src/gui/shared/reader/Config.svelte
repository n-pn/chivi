<script context="module" lang="ts">
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = ['Roboto', 'Merriweather', 'Nunito Sans', 'Lora', 'Roboto Slab']
  const ftsizes = ['Rất nhỏ', 'Khá nhỏ', 'Nhỏ vừa', 'Cỡ chuẩn', 'To vừa', 'Khá to', 'Rất to']

  const r_modes = ['Thường', 'Zen', 'Dev']

  const rmode_descs = [
    'Bấm vào dòng sẽ hiện lên chi tiết dòng',
    'Bấm vào dòng không hiện cửa sổ chi tiết',
    'Xem các cụm từ nếu dùng chế độ dịch máy',
  ]
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import { config as data } from '$lib/stores/config_stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  export let actived = false
</script>

<Slider class="config" bind:actived --slider-width="22rem">
  <svelte:fragment slot="header-left">
    <span class="-icon"><SIcon name="adjustments" /></span>
    <span class="-text">Cài đặt chung</span>
  </svelte:fragment>

  <h4>Giao diện hệ thống</h4>
  <div class="entry">
    <span class="label">Màu nền:</span>
    <field-input>
      {#each wthemes as value}
        <label class="wtheme _{value}" class:_active={value == $data.wtheme}>
          <input type="radio" name="wtheme" {value} bind:group={$data.wtheme} />
        </label>
      {/each}
    </field-input>
  </div>

  <div class="entry">
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
  <div class="entry">
    <span class="label">Cỡ chữ:</span>
    <field-input>
      <button class="m-btn _sm" on:click={() => ($data.rfsize -= 1)} disabled={$data.rfsize == 1}>
        <SIcon name="minus" />
      </button>
      <field-value>{ftsizes[$data.rfsize - 1]}</field-value>
      <button class="m-btn _sm" on:click={() => ($data.rfsize += 1)} disabled={$data.rfsize == 7}>
        <SIcon name="plus" />
      </button>
    </field-input>
  </div>

  <div class="entry">
    <span class="label">Font chữ:</span>
    <field-input>
      <select class="m-input" name="rfface" bind:value={$data.rfface}>
        {#each ftfaces as value, index}
          <option value={index + 1}>{value}</option>
        {/each}
      </select>
    </field-input>
  </div>

  <div class="entry">
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

  <div class="entry">
    <span class="label _sm">Chế độ đọc:</span>
    <field-input>
      {#each r_modes as label, value}
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

  <div class="entry">
    <label class="switch">
      <input type="checkbox" bind:checked={$data.show_z} />
      <span class="switch-label">Hiển thị song song tiếng Trung:</span>
    </label>
  </div>

  <div class="entry" data-tip="Tự động mở khóa chương hoặc tăng giới hạn ký tự">
    <label class="switch">
      <input type="checkbox" bind:checked={$data._auto_} />
      <span class="switch-label">Tự động thanh toán bằng vcoin:</span>
    </label>
  </div>

  <hr />

  <h4>Tinh chỉnh máy dịch</h4>

  <label class="radio" data-tip="Luôn dùng lại kết quả phân tich ngữ pháp cho máy dịch AI">
    <input type="radio" bind:group={$data._regen} value={0} />
    <span>Luôn dùng lại kết quả phân tích có sẵn</span>
    <SIcon class="u-right" name="privi-0" iset="icons" />
  </label>

  <label class="radio" data-tip="Bỏ qua kết quả phân tích cũ đã có khả năng quá thời hạn">
    <input type="radio" bind:group={$data._regen} value={1} disabled={$_user.privi < 2} />
    <span>Dùng lại nếu thời gian lưu dưới hai tuần</span>
    <SIcon class="u-right" name="privi-2" iset="icons" />
  </label>

  <label class="radio" data-tip="Luôn chạy lại công cụ phân tích ngữ pháp cho trải nghiệm tốt nhất">
    <input type="radio" bind:group={$data._regen} value={2} disabled={$_user.privi < 3} />
    <span>Luôn chạy công cụ phân tích ngữ pháp</span>
    <SIcon class="u-right" name="privi-3" iset="icons" />
  </label>
</Slider>

<style lang="scss">
  .links {
    @include flex-ca($gap: 0.5rem);
  }

  h4 {
    margin: 0.75rem;
  }

  .entry {
    @include flex-cy($gap: 0.5rem);
    margin: 0.75rem;
  }

  .radio {
    @include flex-cy($gap: 0.5rem);
    margin: 0 0.75rem;

    :checked + * {
      @include fgcolor(primary);
    }

    :disabled + * {
      @include fgcolor(neutral, 5);
    }
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
  }
</style>
