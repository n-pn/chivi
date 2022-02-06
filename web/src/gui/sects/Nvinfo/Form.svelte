<script context="module">
  const status = ['Còn tiếp', 'Hoàn thành', 'Thái giám']
</script>

<script>
  import { goto } from '$app/navigation'
  import SIcon from '$atoms/SIcon.svelte'

  export let params = {
    author: '',
    btitle: '',
    genres: '',
    bintro: '',
    bcover: '',
    status: 0,
  }

  let error = ''

  async function submit() {
    const body = JSON.stringify(params)
    const opts = {
      headers: { 'Content-Type': 'application/json' },
      method: 'PUT',
      body,
    }

    const res = await fetch('/api/books', opts)

    if (res.ok) {
      const { bslug } = await res.json()
      await goto(`/-${bslug}`)
    } else {
      error = await res.text()
    }
  }
</script>

<article class="m-article nvinfo-upsert">
  <h1>Thêm/sửa thông tin bộ truyện</h1>

  <form action="/api/books" method="POST" on:submit|preventDefault={submit}>
    <form-group>
      <label for="btitle">Tựa sách (tiếng Trung)</label>
      <input
        type="text"
        class="m-input"
        name="btitle"
        placeholder="Tên tựa bộ truyện"
        required
        bind:value={params.btitle} />
    </form-group>

    <form-group>
      <label for="author">Tên tác giả (tiếng Trung)</label>
      <input
        type="text"
        class="m-input"
        name="author"
        placeholder="Tên tác giả bộ truyện"
        required
        bind:value={params.author} />
    </form-group>

    <form-group>
      <label for="bintro">Giới thiệu vắn tắt (tiếng Trung)</label>
      <textarea
        type="text"
        class="m-input"
        name="bintro"
        rows="5"
        placeholder="Giới thiệu vắn tắt nội dung"
        bind:value={params.bintro} />
    </form-group>

    <form-group>
      <label for="genres">Thể loại (tiếng Trung)</label>
      <input
        type="text"
        class="m-input"
        name="genres"
        placeholder="Tách biệt nhiều thể loại bằng dấu cách"
        bind:value={params.genres} />
    </form-group>

    <form-group>
      <label for="bcover">Ảnh bìa truyện (đường link)</label>
      <input
        type="text"
        class="m-input"
        name="bcover"
        placeholder="Hạn chế dùng đường dẫn link tới site chính chủ"
        bind:value={params.bcover} />
    </form-group>

    <form-group>
      <label for="status">Trạng thái truyện</label>
      <form-radio>
        {#each status as label, value}
          <label class="m-radio">
            <input
              type="radio"
              bind:group={params.status}
              name="status"
              {value} />
            <span>{label}</span>
          </label>
        {/each}
      </form-radio>
    </form-group>

    {#if error}
      <form-group>
        <form-error>{error}</form-error>
      </form-group>
    {/if}

    <form-group class="action">
      <button class="m-btn _primary _fill _lg" type="submit">
        <SIcon name="send" />
        <span class="-txt">Lưu thông tin</span>
      </button>
    </form-group>
  </form>
</article>

<style lang="scss">
  article {
    width: 30rem;
    max-width: 100%;
    margin: 1rem auto;

    padding: 1rem var(--gutter);

    @include bdradi();
    @include fgcolor(secd);
    @include bgcolor(tert);
    @include shadow(1);
  }

  form-group {
    display: block;
    margin-top: 1rem;

    &.action {
      @include border($loc: top);
      padding-top: 1rem;
      text-align: right;
    }

    > label {
      display: block;
      font-weight: 500;
      margin-bottom: 0.5rem;
    }
  }

  form-radio {
    display: block;
  }

  .m-radio {
    display: inline-block;
    margin-right: 0.5rem;
  }

  .m-input {
    display: block;
    width: 100%;
  }
</style>
