<script context="module" lang="ts">
  import { config as data, get_user } from '$lib/stores'
  import { ctrl as lookup } from '$gui/parts/Lookup.svelte'

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
  // prettier-ignore
  const r_modes = [['Thường', 0], ['Zen', 1], ['Dev', 2]]

  const c_algos = [
    ['Hmeg', 'hmeg', 'Chọn mô-dun Ernie Gram'],
    ['Hmeb', 'hmeb', 'Chọn mô-đun Electra Base'],
    ['Auto', 'auto', 'Tự động chọn dữ liệu đang có sẵn'],
  ]
</script>

<script lang="ts">
  import { browser } from '$app/environment'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  let elem: HTMLElement
  $: if (elem) elem.focus()

  const _user = get_user()

  async function update_wtheme(wtheme: string) {
    if ($_user.privi < 0) return

    await fetch('/_db/_self/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ wtheme }),
    })
  }

  $: if (browser && $data) {
    write_cookie('w_udic', $data.w_udic ? 't' : 'f')

    write_cookie('show_z', $data.show_z ? 't' : 'f')
    write_cookie('show_c', $data.show_c ? 't' : 'f')

    write_cookie('c_algo', $data.c_algo)
    write_cookie('c_auto', $data.c_auto ? 't' : 'f')

    write_cookie('theme', $data.wtheme)
  }

  const write_cookie = (key: string, value: string) => {
    document.cookie = `${key}=${value}; max-age=31536000; path=/`
  }

  export let actived = true
</script>

<Slider class="config" bind:actived --slider-width="22rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="adjustments-alt" /></div>
    <div class="-text">Cài đặt</div>
  </svelte:fragment>

  <config-item>
    <field-label>Màu nền:</field-label>
    <field-input>
      {#each wthemes as value}
        <label class="wtheme _{value}" class:_active={value == $data.wtheme}>
          <input
            type="radio"
            name="wtheme"
            {value}
            bind:group={$data.wtheme}
            on:change={() => update_wtheme(value)} />
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <field-label>Cỡ chữ:</field-label>
    <field-input>
      <button
        class="m-btn _sm"
        on:click={() => ($data.ftsize -= 1)}
        disabled={$data.ftsize == 1}>
        <SIcon name="minus" />
      </button>
      <field-value>{ftsizes[$data.ftsize - 1]}</field-value>
      <button
        class="m-btn _sm"
        on:click={() => ($data.ftsize += 1)}
        disabled={$data.ftsize == 5}>
        <SIcon name="plus" />
      </button>
    </field-input>
  </config-item>

  <config-item>
    <field-label>Font chữ:</field-label>
    <field-input>
      <select class="m-input" name="ftface" bind:value={$data.ftface}>
        {#each ftfaces as value, index}
          <option value={index + 1}>{value}</option>
        {/each}
      </select>
    </field-input>
  </config-item>

  <config-item>
    <field-label>Giãn dòng:</field-label>
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
  </config-item>

  <config-sep />

  <config-item>
    <field-label class="small">Chế độ đọc:</field-label>
    <field-input>
      {#each r_modes as [label, value]}
        <label class:_active={value == $data.r_mode}>
          <input type="radio" name="r_mode" {value} bind:group={$data.r_mode} />
          <span>{label}</span>
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$data.show_z} />
      <span class="switch-label">Hiển thị tiếng Trung gốc:</span>
    </label>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$data.w_udic} />
      <span class="switch-label">Sử dụng từ điển cá nhân:</span>
    </label>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$lookup.enabled} />
      <span class="switch-label">Luôn bật ô giải nghĩa:</span>
    </label>
  </config-item>

  <config-sep />

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$data.show_c} />
      <span class="switch-label">Hiển thị cây ngữ pháp:</span>
    </label>
  </config-item>

  <config-item>
    <field-label class="small">Thuật toán:</field-label>
    <field-input>
      {#each c_algos as [label, value, chint]}
        <label class:_active={value == $data.c_algo} data-tip={chint}>
          <input type="radio" name="c_algo" {value} bind:group={$data.c_algo} />
          <span>{label}</span>
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$data.c_auto} />
      <span class="switch-label">Tự động phân tích ngữ pháp:</span>
    </label>
  </config-item>

  <div class="config-hint">
    * Chỉ áp dụng cho người dùng quyền hạn 2 trở lên!
  </div>
</Slider>

<style lang="scss">
  config-item {
    @include flex-cy($gap: 0.5rem);
    padding: 0 1rem;
    margin-top: 1rem;
  }

  .config-hint {
    padding: 0 1rem;
    margin-top: 1rem;
  }

  config-sep {
    display: block;
    margin-top: 1.5rem;
    @include border($loc: top);
  }

  field-label {
    display: inline-block;
    min-width: 33%;
    // @include ftsize(sm);
    font-weight: 500;

    &.small {
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
</style>
