<script context="module">
  import { session } from '$app/stores'

  const wthemes = ['Light', 'Dark', 'Oled']
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
    {#each wthemes as label}
      <label class="m-radio">
        <input
          type="radio"
          name="wtheme"
          value={label.toLowerCase()}
          on:click={() => update_setting({ wtheme: label.toLowerCase() })}
          bind:group={$session.wtheme} />
        <span>{label}</span>
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
