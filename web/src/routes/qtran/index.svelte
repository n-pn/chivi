<script context="module" lang="ts">
  export async function load({ url }) {
    const dname = url.searchParams.get('dname') || 'combine'
    const input = url.searchParams.get('input')

    const topbar = {
      left: [['Dịch nhanh', 'bolt', { href: '/qtran' }]],
    }
    return { props: { dname, input: input }, stuff: { topbar } }
  }
</script>

<script lang="ts">
  import { Footer, SIcon, Crumb } from '$gui'

  import { goto } from '$app/navigation'

  export let dname = 'combine'
  export let input = ''

  let error = ''
  async function submit() {
    // if ($session.privi < 0) return

    if (input.length > 10000) {
      error = `Số ký tự phải nhỏ hơn 10000, hiện tại: ${input.length}`
      return
    }

    const url = `/api/qtran/posts`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input, dname }),
    })

    if (res.ok) {
      const { ukey } = await res.json()
      goto(`/qtran/posts/${ukey}`)
    } else {
      error = await res.text()
    }
  }
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Crumb tree={[['Dịch nhanh', '/qtran']]} />

<div class="input">
  <textarea
    class="m-input"
    lang="zh"
    class:_error={error}
    bind:value={input}
    placeholder="Nhập dữ liệu vào đây" />
</div>

{#if error}
  <div class="error">{error}</div>
{/if}

<Footer>
  <div class="foot">
    <button class="m-btn" on:click={() => (input = '')}>
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
