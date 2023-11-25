<script lang="ts">
  async function load_rdmemos(): Promise<Array<CV.Rdmemo>> {
    const url = `/_rd/rdmemos?rtype=rdlog&lm=4`
    const res = await fetch(url)

    if (!res.ok) {
      alert(await res.text())
      return []
    }

    const data = await res.json()
    return data.items
  }

  const stypes = [
    ['', 'Tất cả'],
    ['?sn=wn', 'Truyện chữ'],
    ['?sn=up', 'Sưu tầm'],
    ['?sn=rm', 'Liên kết'],
  ]

  import RdchapList from '$gui/parts/rdmemo/RdchapList.svelte'
</script>

<details open>
  <summary>Chương tiết vừa đọc</summary>

  <nav class="links">
    {#each stypes as [filter, label]}
      <a class="m-btn _xs _primary" href="/me/rdlog{filter}">{label}</a>
    {/each}
  </nav>

  <div class="chaps">
    {#await load_rdmemos()}
      <div class="d-empty-sm">Đang tải lịch sử đọc truyện.</div>
    {:then items}
      <RdchapList {items} />
    {/await}
  </div>
</details>

<style lang="scss">
  .links {
    margin-bottom: 0.5rem;
    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }
  }

  .chaps {
    margin-bottom: 0.5rem;
  }
</style>
