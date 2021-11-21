<script context="module">
  import { session } from '$app/stores'
  import { config } from '$lib/stores'

  const ftsizes = ['Rất nhỏ', 'Nhỏ vừa', 'Cỡ chuẩn', 'To vừa', 'Rất to']
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = ['Roboto', 'Merriweather', 'Nunito Sans', 'Lora']

  // const tlmodes = ['Cơ bản', 'Nâng cao']

  function save_config(name, data) {
    localStorage.setItem(name, data)
    config.update((x) => ({ ...x, [name]: data }))
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let actived = false

  let config_elem
  $: if (actived && config_elem) config_elem.focus()

  $: ftsize = +$config.ftsize || 3
  $: ftface = +$config.ftface || 1

  async function update_wtheme(wtheme) {
    save_config('wtheme', wtheme)
    await call_update({ wtheme, tlmode: $session.tlmode })
  }

  async function call_update(params) {
    const res = await fetch('/api/user/setting', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (res.ok) $session = await res.json()
    else console.log('Error: ' + (await res.text()))
  }
</script>

<config-main bind:this={config_elem}>
  <config-head>
    <config-title>Cài đặt</config-title>
    <button class="m-btn _sm" data-kbd="esc" on:click={() => (actived = false)}>
      <SIcon name="x" />
    </button>
  </config-head>

  <config-item>
    <field-label>Màu nền:</field-label>
    <field-input>
      {#each wthemes as value}
        <label class="wtheme _{value}" class:_active={value == $config.wtheme}>
          <input
            type="radio"
            name="wtheme"
            {value}
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
        on:click={() => save_config('ftsize', ftsize - 1)}
        disabled={ftsize == 1}>
        <SIcon name="minus" />
      </button>

      <field-value>
        {ftsizes[ftsize - 1]}
      </field-value>

      <button
        class="m-btn _sm"
        on:click={() => save_config('ftsize', ftsize + 1)}
        disabled={ftsize == 5}>
        <SIcon name="plus" />
      </button>
    </field-input>
  </config-item>

  <config-item>
    <field-label>Font chữ:</field-label>
    <field-input>
      <select
        class="m-input"
        name="ftface"
        bind:value={ftface}
        on:change={() => save_config('ftface', ftface)}>
        {#each ftfaces as value, index}
          <option value={index + 1}>{value}</option>
        {/each}
      </select>
    </field-input>
  </config-item>
</config-main>

<config-wrap on:click={() => (actived = false)} />

<style lang="scss">
  config-main {
    display: block;
    width: 18rem;
    position: absolute;
    top: 3.5rem;

    z-index: 90;
    right: var(--gutter);
    // @include bps(margin-right, 0, $tl: var(--gutter));
    padding-bottom: 1rem;

    @include fgcolor(secd);
    @include bgcolor(secd);
    @include bdradi();
    @include shadow(2);

    @include linesd(--bd-soft, $ndef: false);
  }

  config-wrap {
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
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

  field-label {
    display: inline-block;
    width: 28%;
    font-weight: 500;
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
    margin-right: 0.25rem;
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
  }

  // .radio {
  //   line-height: 1.25;
  //   padding: 0.5rem 0;
  //   @include fgcolor(tert);
  //   @include flex($center: none, $gap: 0.675rem);
  // }

  // .label {
  //   font-weight: 500;
  //   display: block;
  //   // text-align: center;
  // }

  // .ftsize {
  //   font-variant: small-caps;
  // }

  // .config {
  //   padding: 0.5rem 0.75rem;
  //   @include border(--bd-main, $loc: bottom);
  // }

  // .tlmode {
  //   @include fgcolor(tert);
  //   @include ftsize(sm);
  //   line-height: 1.25rem;
  // }
</style>
