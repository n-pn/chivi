<script lang="ts">
  import { goto } from '$app/navigation'

  import { Footer, SIcon, Crumb } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  let error = ''
  async function submit() {
    // if ($session.privi < 0) return

    if (data.input.length > 10000) {
      error = `Số ký tự phải nhỏ hơn 10000, hiện tại: ${data.input.length}`
      return
    }

    const url = `/api/qtran/posts`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: data.input, dname: data.dname }),
    })

    if (res.ok) {
      const { ukey } = await res.json()
      goto(`/qtran/posts/${ukey}`)
    } else {
      error = await res.text()
    }
  }
</script>

<Crumb tree={[['Dịch nhanh', '/qtran']]} />

<div class="input">
  <textarea
    class="m-input"
    lang="zh"
    class:_error={error}
    bind:value={data.input}
    placeholder="Nhập dữ liệu vào đây" />
</div>

{#if error}
  <div class="error">{error}</div>
{/if}

<Footer>
  <div class="foot">
    <button class="m-btn" on:click={() => (data.input = '')}>
      <SIcon name="eraser" />
      <span>Xoá</span>
    </button>

    <button class="m-btn _primary _fill" on:click={submit}>
      <span>Dịch nhanh</span>
    </button>
  </div>
</Footer>

<style lang="scss">
  .m-input {
    width: 100%;
    min-height: calc(100vh - 15.5rem);

    padding: var(--gutter-small) var(--gutter);

    &::placeholder {
      font-style: normal;
      text-align: center;
    }
  }

  .error {
    @include fgcolor(harmful, 5);
    text-align: center;
    padding: 0.5rem;
  }

  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
