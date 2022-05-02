<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'
  import { book_status } from '$utils/nvinfo_utils'

  const assigns = [
    'btitle_zh',
    'btitle_vi',

    'author_vi',
    'author_zh',

    'status',
    'bintro',
  ]

  export class Params {
    btitle_zh: string = ''
    author_zh: string = ''

    btitle_vi: string = ''
    author_vi: string = ''

    status: number = 0
    genres: string = ''

    bintro: string = ''
    bcover: string = ''

    constructor(nvinfo?: CV.Nvinfo) {
      if (!nvinfo) return

      for (const key in assigns) this[key] = nvinfo[key]

      this.bcover = nvinfo.scover
      this.genres = nvinfo.genres.join(',')
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let params: Params
  let errors: string

  async function submit() {
    const [stt, data] = await api_call(fetch, 'books', params, 'PUT')
    if (stt >= 400) errors = data as string
    else await goto(`/-${data.bslug}`)
  }
</script>

<article class="m-article nvinfo-upsert">
  <h1>Thêm/sửa thông tin bộ truyện</h1>

  <form action="/api/books" method="POST" on:submit|preventDefault={submit}>
    <form-group>
      <label for="btitle_zh">Tựa sách (tiếng Trung)</label>
      <input
        type="text"
        class="m-input"
        name="btitle_zh"
        placeholder="Tên tựa bộ truyện"
        required
        bind:value={params.btitle_zh} />
    </form-group>

    <form-group>
      <label for="author_zh">Tên tác giả (tiếng Trung)</label>
      <input
        type="text"
        class="m-input"
        name="author_zh"
        placeholder="Tên tác giả bộ truyện"
        required
        bind:value={params.author_zh} />
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
        placeholder="Tách biệt nhiều thể loại bằng dấu phẩy"
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
        {#each book_status as label, value}
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

    {#if errors}
      <form-group>
        <form-error>{errors}</form-error>
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
    width: 35rem;
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
