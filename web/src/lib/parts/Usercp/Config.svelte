<script context="module">
  import { session } from '$app/stores'

  const wthemes = ['light', 'warm', 'dark', 'oled']
  const tlmodes = ['Cơ bản', 'Nâng cao']
</script>

<script>
  export let actived

  async function update_setting({
    tlmode = $session.tlmode,
    wtheme = $session.wtheme,
  }) {
    const res = await fetch('/api/user/setting', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tlmode, wtheme }),
    })

    if (res.ok) {
      $session = await res.json()
      actived = false
    } else {
      console.log('Error: ' + (await res.text()))
    }
  }
</script>

<div class="config">
  <div class="radio">
    <span class="label">Giao diện:</span>
    {#each wthemes as wtheme}
      <label class="wtheme _{wtheme}" class:_active={wtheme == $session.wtheme}>
        <input
          type="radio"
          name="wtheme"
          value={wtheme}
          on:click={() => update_setting({ wtheme: wtheme })}
          bind:group={$session.wtheme} />
        <span>{wtheme}</span>
      </label>
    {/each}
  </div>
</div>

<div class="config">
  <div class="radio">
    <span class="label">Chế độ dịch:</span>
    {#each tlmodes as label, idx}
      <label class="m-radio">
        <input
          type="radio"
          name="tlmode"
          value={idx + 1}
          on:click={() => update_setting({ tlmode: idx + 1 })}
          bind:group={$session.tlmode} />
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
