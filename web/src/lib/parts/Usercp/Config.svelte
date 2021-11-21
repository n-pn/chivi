<script context="module">
  import { session } from '$app/stores'
  import { config } from '$lib/stores'

  const ftsizes = ['xs', 'sm', 'md', 'lg', 'xl']
  const wthemes = ['light', 'warm', 'dark', 'oled']
  const ftfaces = ['Roboto', 'Merriweather', 'Nunito Sans', 'Lora']

  const tlmodes = ['Cơ bản', 'Nâng cao']

  function save_config(name, data) {
    localStorage.setItem(name, data)
    config.update((x) => (x[name] = data))
  }
</script>

<script>
  export let actived

  async function update_wtheme(wtheme) {
    save_config('wtheme', wtheme)
    await call_update({ wtheme, tlmode: $session.tlmode })
  }

  async function update_tlmode(tlmode) {
    await call_update({ tlmode, wtheme: $config.wtheme })
  }

  async function call_update(params) {
    const res = await fetch('/api/user/setting', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (res.ok) {
      $session = await res.json()
      actived = false
    } else {
      console.log('Error: ' + (await res.text()))
    }
  }
</script>

<config-main>
  <config-item>
    <field-label>Màu nền màn hình:</field-label>
    <field-input>
      {#each wthemes as value}
        <label class="wtheme _{value}" class:_active={value == $config.wtheme}>
          <input
            type="radio"
            name="wtheme"
            {value}
            on:change={() => update_wtheme(value)} />
          <span>{value}</span>
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <field-label>Kích thước font chữ:</field-label>
    <field-input>
      {#each ftsizes as value}
        <label class="ftsize _{value}" class:_active={value == $config.ftsize}>
          <input
            type="radio"
            name="ftsize"
            {value}
            on:change={() => save_config('ftsize', value)} />
          <span>{value}</span>
        </label>
      {/each}
    </field-input>
  </config-item>

  <config-item>
    <field-label>Loại font chữ:</field-label>
    <field-input>
      {#each ftfaces as value}
        <label class="ftface _{value}" class:_active={value == $config.ftface}>
          <input
            type="radio"
            name="ftface"
            {value}
            on:change={() => save_config('ftface', value)} />
          <span>{value}</span>
        </label>
      {/each}
    </field-input>
  </config-item>
</config-main>

<div class="config">
  <div class="radio">
    <span class="label">Chế độ dịch:</span>
    {#each tlmodes as label, idx}
      <label class="m-radio">
        <input
          type="radio"
          name="tlmode"
          value={idx}
          bind:group={$session.tlmode}
          on:click={() => update_tlmode(idx)} />
        <span>{label}</span>
      </label>
    {/each}
  </div>

  <div class="tlmode">
    {#if $session.tlmode < 2}
      Áp dụng một số luật ngữ pháp cơ bản, phần lớn chính xác. <strong
        >(Khuyến khích dùng)</strong>
    {:else}
      Sử dụng đầy đủ các luật ngữ pháp đang được hỗ trợ, đảo vị trí của các từ
      trong câu cho thuần việt. <em>(Đang thử nghiệm)</em>
    {/if}
  </div>
</div>

<style lang="scss">
  .wtheme {
    text-transform: capitalize;
    cursor: pointer;
    display: inline-flex;

    input {
      display: none;
    }

    &:hover {
      @include fgcolor(primary, 5);
    }

    &._active {
      font-weight: 500;
      @include fgcolor(primary, 5);
    }

    &:before {
      content: '';
      display: inline-block;
      width: 1rem;
      height: 1rem;
      margin-top: 0.1rem;
      margin-right: 0.2rem;
      margin-left: -0.25rem;
      @include bdradi;
    }

    &._light:before {
      @include bgcolor(neutral, 0);
      @include linesd(--bd-main, $inset: false);
    }

    &._warm:before {
      @include bgcolor(orange, 1);
      @include linesd(--bd-main, $inset: false);
    }

    &._dark:before {
      @include bgcolor(primary, 9);
    }

    &._oled:before {
      background: #000;
    }

    @include tm-dark {
      &._light:before,
      &._warm:before {
        --linesd: 0;
      }

      &._dark:before,
      &._oled:before {
        @include linesd(--bd-main, $inset: false);
      }
    }
  }

  .radio {
    line-height: 1.25;
    padding: 0.5rem 0;
    @include fgcolor(tert);
    @include flex($center: none, $gap: 0.675rem);
  }

  .label {
    font-weight: 500;
    display: block;
    // text-align: center;
  }

  .ftsize {
    font-variant: small-caps;
  }

  .config {
    padding: 0.5rem 0.75rem;
    @include border(--bd-main, $loc: bottom);
  }

  .tlmode {
    @include fgcolor(tert);
    @include ftsize(sm);
    line-height: 1.25rem;
  }
</style>
