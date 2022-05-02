<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'
  import { book_status } from '$utils/nvinfo_utils'

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

      this.btitle_zh = nvinfo.btitle_zh
      this.btitle_vi = nvinfo.btitle_vi

      this.author_zh = nvinfo.author_zh
      this.author_vi = nvinfo.author_vi

      this.status = nvinfo.status

      this.bintro = nvinfo.bintro
      this.bcover = nvinfo.bcover
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

<article class="article">
  <header>
    <slot name="header">
      <h1>Thêm/sửa thông tin bộ truyện</h1>
    </slot>
  </header>

  <form action="/api/books" method="POST" on:submit|preventDefault={submit}>
    <form-group>
      <form-field>
        <label class="form-label" for="btitle_zh">Tựa sách tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="btitle_zh"
          placeholder="Tên tựa bộ truyện"
          required
          bind:value={params.btitle_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="btitle_vi">Tựa sách tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="btitle_vi"
          placeholder="Có thể để trắng"
          required
          bind:value={params.btitle_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="author_zh"
          >Tên tác giả tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="author_zh"
          placeholder="Tên tác giả bộ truyện"
          required
          bind:value={params.author_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="author_vi">Tên tác giả tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="author_vi"
          placeholder="Có thể để trắng"
          required
          bind:value={params.author_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="bintro"
          >Giới thiệu vắn tắt (tiếng Trung)</label>
        <textarea
          type="text"
          class="m-input"
          name="bintro"
          rows="5"
          placeholder="Giới thiệu vắn tắt nội dung"
          bind:value={params.bintro} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="genres">Thể loại (tiếng Trung)</label>
        <input
          type="text"
          class="m-input"
          name="genres"
          placeholder="Tách biệt nhiều thể loại bằng dấu phẩy"
          bind:value={params.genres} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="bcover"
          >Ảnh bìa truyện (đường link)</label>
        <input
          type="text"
          class="m-input"
          name="bcover"
          placeholder="Hạn chế dùng đường dẫn link tới site chính chủ"
          bind:value={params.bcover} />
      </form-field>
    </form-group>

    <form-group>
      <label class="label" for="status">Trạng thái truyện</label>

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
    @include bp-min(tl) {
      @include padding-x(2rem);
    }
  }

  header {
    @include border($loc: bottom);
    margin-bottom: var(--gutter);
  }

  form-group {
    display: flex;
    margin-top: 1.5rem;
    gap: var(--gutter);

    @include bps(flex-direction, column, $tm: row);

    &.action {
      @include border($loc: top);
      justify-content: center;
      padding-top: 1rem;
    }
  }

  form-field {
    display: block;
    position: relative;
    flex: 1;

    .m-input {
      padding-top: 0.75rem;
      padding-bottom: 0.75rem;
    }
  }

  .form-label {
    position: absolute;
    background: inherit;
    top: -0.75rem;
    left: 0.75rem;
    padding: 0 0.25rem;
    // transition: all 0.1s ease-in-out;

    @include ftsize(sm);
    @include bgcolor(tert);
    @include fgcolor(tert);
  }

  .label {
    display: block;
    font-weight: 500;
    margin-bottom: 0.5rem;
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
