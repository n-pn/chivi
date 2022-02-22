<script context="module" lang="ts">
  import { config_data as data, config_ctrl as ctrl } from '$lib/stores'
  import { ctrl as lookup } from '$gui/parts/Lookup.svelte'

  const ftsizes = ['Rất nhỏ', 'Nhỏ vừa', 'Cỡ chuẩn', 'To vừa', 'Rất to']
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = ['Roboto', 'Merriweather', 'Nunito Sans', 'Lora']

  // const textlhs = [150, 150, 150, 150]
  // prettier-ignore
  const renders = [['Thường', 0], ['Zen', -1], ['Dev', 1]]
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  let config_elem: HTMLElement
  $: if ($ctrl.actived && config_elem) config_elem.focus()

  async function update_wtheme(wtheme: string) {
    await fetch('/api/user/setting', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ wtheme }),
    })
  }
</script>

<config-main bind:this={config_elem}>
  <config-head>
    <config-title>Cài đặt</config-title>
    <button class="m-btn _sm" data-kbd="esc" on:click={ctrl.hide}>
      <SIcon name="x" />
    </button>
  </config-head>

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
    <field-label class="small">Chế độ:</field-label>
    <field-input>
      {#each renders as [label, value]}
        <label class:_active={value == $data.render}>
          <input type="radio" name="render" {value} bind:group={$data.render} />
          <span>{label}</span>
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$data.showzh} />
      <span class="switch-label">Hiển thị tiếng Trung gốc:</span>
    </label>
  </config-item>

  <config-item>
    <label class="switch">
      <input type="checkbox" bind:checked={$lookup.enabled} />
      <span class="switch-label">Luôn bật ô giải nghĩa:</span>
    </label>
  </config-item>
</config-main>

<config-wrap on:click={ctrl.hide} />

<style lang="scss">
  config-main {
    display: block;
    width: 18rem;
    position: absolute;
    top: 3.5rem;

    z-index: 90;
    right: 0;
    padding: 0 0 1rem;

    @include fgcolor(secd);
    @include bgcolor(secd);
    @include bdradi();
    @include shadow(3);

    @include tm-dark {
      @include linesd(--bd-main);
    }
  }

  config-wrap {
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: 100vh;
    z-index: 89;
  }

  config-head {
    display: flex;
    padding: 0.5rem 1rem;
    @include border($loc: bottom);
  }

  config-title {
    font-weight: 500;
    flex: 1;
    line-height: 2rem;
    @include ftsize(lg);
  }

  config-item {
    @include flex-cy($gap: 0.5rem);
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
    width: 33%;
    // @include ftsize(sm);
    font-weight: 500;

    &.small {
      width: 25%;
    }
  }

  field-input {
    flex: 1;
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
