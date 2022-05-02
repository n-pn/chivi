<script context="module" lang="ts">
  import { bgenres } from '$lib/constants'

  const fields = ['btitle_vi', 'author_vi', 'status', 'bintro', 'bcover']

  export class Params {
    nvinfo?: CV.Nvinfo

    btitle_zh: string = ''
    author_zh: string = ''

    btitle_vi: string = ''
    author_vi: string = ''

    status: number = 0
    genres: Array<string> = []

    bintro: string = ''
    bcover: string = ''

    constructor(nvinfo?: CV.Nvinfo) {
      this.nvinfo = nvinfo
      if (!nvinfo) return

      this.btitle_zh = nvinfo.btitle_zh
      this.author_zh = nvinfo.author_zh
      this.genres = nvinfo.genres
      for (const field of fields) this[field] = nvinfo[field]
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'
  import { book_status } from '$utils/nvinfo_utils'

  import { SIcon } from '$gui'

  export let nvinfo: CV.Nvinfo = undefined

  $: params = new Params(nvinfo)
  let errors: string

  async function submit() {
    const nvinfo = this.nvinfo || {}

    const output = {
      btitle_zh: this.btitle_zh,
      author_zh: this.author_zh,
      genres: this.genres.join(','),
    }

    for (const field of fields) {
      const value = this[field].trim()
      if (value && value != nvinfo[field]) output[field] = value
    }

    const [stt, data] = await api_call(fetch, 'books', output, 'PUT')
    if (stt >= 400) errors = data as string
    else await goto(`/-${data.bslug}`)
  }

  function remove_genre(genre: string) {
    params.genres = params.genres.filter((x) => x != genre)
  }

  function add_genre(genre: string) {
    params.genres = [...params.genres, genre]
  }

  let show_genres_menu = false
  let show_genres_more = false
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
          disabled={!!params.nvinfo}
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
          disabled={!!params.nvinfo}
          bind:value={params.author_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="author_vi">Tên tác giả tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="author_vi"
          placeholder="Có thể để trắng"
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
        <label class="form-label" for="bcover">Ảnh bìa truyện</label>
        <input
          type="text"
          class="m-input"
          name="bcover"
          placeholder="Liên kết địa chỉ file ảnh"
          bind:value={params.bcover} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="label" for="genres">Thể loại</label>

        <div class="m-chips ">
          {#each params.genres as genre}
            <button
              type="button"
              class="m-chip _success"
              on:click={() => remove_genre(genre)}>
              <span>{genre}</span>
              <SIcon name="x" />
            </button>
          {/each}

          <button
            type="button"
            class="m-chip"
            on:click={() => (show_genres_menu = !show_genres_menu)}>
            <SIcon name={show_genres_menu ? 'minus' : 'plus'} />
          </button>
        </div>

        {#if show_genres_menu}
          <div class="m-chips suggest">
            {#each bgenres as [vgenre, _slug, primary_genre]}
              {@const included = params.genres.includes(vgenre)}
              {@const revealed = show_genres_more || primary_genre}
              <button
                type="button"
                class="m-chip _xs"
                hidden={included || !revealed}
                on:click={() => add_genre(vgenre)}>
                <span>{vgenre}</span>
                <SIcon name="plus" />
              </button>
            {/each}

            <button
              type="button"
              class="m-chip _xs"
              on:click={() => (show_genres_more = !show_genres_more)}>
              <SIcon
                name={show_genres_more ? 'chevron-left' : 'chevron-right'} />
            </button>
          </div>
        {/if}
      </form-field>
    </form-group>

    <form-group>
      <form-field>
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
      </form-field>
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
    padding-bottom: var(--gutter-small);
    margin-bottom: var(--gutter);
  }

  form-group {
    display: flex;
    margin-top: 1.5rem;
    gap: 0.75rem;

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
    top: -0.5rem;
    left: 0.75rem;
    line-height: 1rem;
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

  .suggest {
    margin-top: 0.75rem;
    margin-right: -0.25rem;
    margin-bottom: -0.25rem;

    > * {
      margin-right: 0.25rem;
      margin-bottom: 0.25rem;
    }
  }
</style>
