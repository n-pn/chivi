<script lang="ts">
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let can_edit = true
  export let edit_url: string
  export let seed_data: CV.WnSeed

  export let ztitle: string

  let slink = ''
  let error = ''

  const add_seed = () => {
    if (seed_data.links.includes(slink)) return
    seed_data.links.push(slink)
    update_rm_links(seed_data.links)
    slink = ''
  }

  const delete_seed = (slink: string) => {
    seed_data.links = seed_data.links.filter((x) => x != slink)
    update_rm_links(seed_data.links)
  }

  const make_slink_as_main = (slink: string) => {
    seed_data.links = seed_data.links.filter((x) => x != slink)
    seed_data.links.unshift(slink)
    update_rm_links(seed_data.links)
  }

  const update_rm_links = async (rm_links: string[]) => {
    try {
      await api_call(edit_url, { rm_links }, 'PATCH')
      seed_data = seed_data
    } catch (ex) {
      error = ex.body.message
    }
  }

  const sources = [
    {
      site: 'uukanshu.com',
      href: 'https://www.uukanshu.com',
    },
    {
      site: '69shu.com',
      href: 'https://www.69shu.com',
    },

    {
      site: '133txt.com',
      href: 'https://www.133txt.com',
      desc: 'Nguồn mới thêm, nhiều truyện, có cả truyện từ ciweimao.',
    },

    {
      site: 'b5200.org',
      href: 'http://www.b5200.org',
      desc: 'Nguồn mới thêm, chưa kiểm tra.',
    },
    {
      site: 'bxwx.io',
      href: 'https://www.bxwx.io',
      desc: 'Nguồn mới thêm, chưa kiểm tra.',
    },
    {
      site: 'xbiquge.so',
      href: 'http://www.xbiquge.so',
      desc: `Nguồn sống dai, nhưng ít truyện.`,
    },
    {
      site: 'hetushu.com',
      href: 'https://www.hetushu.com',
      desc: 'Text đẹp, chủ yếu là truyện đã hoàn bản.',
    },
    {
      site: 'ptwxz.com',
      href: 'https://www.ptwxz.com',
      desc: 'Nguồn cũ sống dai, có nhiều truyện cũ, text không quá tốt.',
    },
    {
      site: 'biqu5200.net',
      href: 'http://www.biqu5200.net',
      desc: 'Nguồn rác, hay đứt kết nối, dùng tạm.',
    },
    {
      site: 'paoshu8.com',
      href: 'http://www.paoshu8.com',
      desc: 'Nguồn chậm dễ đột tử, có một vài truyện hiếm',
    },
  ]

  $: search = 'https://www.google.com/search?q=' + ztitle
</script>

<h4>Các liên kết tới nguồn ngoài hiện tại:</h4>

<p class="explain">
  <SIcon name="alert-circle" />
  <em>
    Bạn có thể bấm vào biểu tượng <SIcon name="star" /> để thay đổi nguồn được chọn
    mặc định khi đổi mới.
  </em>
</p>

<table>
  <thead>
    <tr>
      <th>Đường dẫn</th>
      <th align="center">Hành động</th>
    </tr>
  </thead>

  <tbody>
    {#each seed_data.links as slink, index}
      <tr>
        <td>
          <a href={slink} class="slink" rel="noreferrer" target="_blank"
            >{slink}</a>
        </td>
        <td align="center">
          <button
            class="m-btn _xs"
            class:_active={index < 1}
            disabled={index < 1}
            data-tip="Làm nguồn ngoài mặc định"
            on:click={() => make_slink_as_main(slink)}>
            <SIcon name="star" />
          </button>

          <button
            class="m-btn _xs _harmful"
            data-tip="Xóa khỏi danh sách"
            on:click={() => delete_seed(slink)}>
            <SIcon name="trash" />
            <span>Xóa</span>
          </button>
        </td>
      </tr>
    {/each}

    <tr>
      <td class="input">
        <input
          class="m-input _sm"
          type="link"
          bind:value={slink}
          placeholder="Thêm nguồn mới" />
      </td>
      <td align="center">
        <button
          class="m-btn _sm _primary _fill"
          disabled={!can_edit}
          on:click={add_seed}>
          <SIcon name="square-plus" />
          <span>Thêm</span>
        </button>
      </td>
    </tr>
  </tbody>
</table>

<p class="warning">
  <strong
    >Hãy kiểm tra kỹ đường dẫn nguồn trước khi thêm. Đường dẫn nguồn phải trỏ
    tới trang chứa danh sách chương tiết. Đường dẫn sai lệch sẽ không trả về kết
    quả bạn mong muốn.</strong>
</p>

<p class="warning">
  Lưu ý 2: Bạn có thể thêm nguồn bất kỳ, hệ thống sẽ thử nghiệm đọc dữ liệu từ
  nguồn nếu có thể. Nhưng để đạt được kết quả tốt nhất, hãy lựa chọn từ các
  nguồn được hỗ trợ bên dưới:
</p>

<details>
  <summary>Các nguồn ngoài đang được hỗ trợ</summary>
  <table>
    {#each sources as { site, href }}
      <tr>
        <td>
          <a {href} rel="noreferrer" target="_blank">
            {href}
            <SIcon name="external-link" />
          </a>
        </td>
        <td align="right">
          <a
            class="search"
            href="{search} site:{site}"
            rel="noreferrer"
            target="_blank">
            <span>Tìm truyện</span>
          </a>
        </td>
      </tr>
    {/each}
  </table>
  <p><em> Liên hệ với ban quản trị để được hỗ trợ thêm các nguồn mới!</em></p>
</details>

<footer />

<style lang="scss">
  th,
  td {
    border-left: none;
    border-right: none;
    border-color: var(--bd-soft);
  }

  table {
    margin: 1rem 0;
  }

  a {
    @include clamp();
    @include fgcolor(primary, 5);
    @include hover {
      @include fgcolor(primary, 6);
    }
  }

  td.input {
    padding-left: 0;
    padding-right: 0;
  }

  input {
    width: 100%;
    padding-left: 0.5rem;
    padding-right: 0.5rem;

    border-color: var(--bd-soft);
  }

  button + button {
    margin-left: 0.25rem;
  }

  button._active {
    @include fgcolor(warning, 5);
  }

  .search {
    font-style: italic;
  }

  .explain {
    @include fgcolor(tert);

    :global(svg) {
      // vertical-align: sub;
      font-size: 0.95em;
      margin-bottom: 0.2em;
    }
  }

  .warning {
    @include fgcolor(warning, 5);
    margin-top: 1rem;
  }

  details {
    margin-top: 1rem;
  }

  summary {
    font-style: italic;
  }

  p,
  h4 {
    margin-top: 0.75rem;
  }
</style>
