<script lang="ts">
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { goto } from '$app/navigation'

  export let can_edit = true
  export let edit_url: string
  export let seed_data: CV.Wnseed

  export let ztitle: string

  let rm_link = seed_data.rlink

  let error = ''

  const update_rm_link = async () => {
    try {
      await api_call(edit_url, { rm_link }, 'PATCH')
      seed_data = seed_data
      await goto('..')
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
      site: 'xbiquge.bz',
      href: 'http://www.xbiquge.bz',
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

<label class="form-label" for="rm_link">Liên kết tới nguồn ngoài:</label>

<div class="input">
  <input
    class="m-input _sm"
    type="link"
    name="rm_link"
    bind:value={rm_link}
    placeholder="Thêm nguồn mới" />

  <button
    class="m-btn _sm _primary _fill"
    disabled={!rm_link || !can_edit}
    on:click={update_rm_link}>
    <SIcon name="square-plus" />
    <span>Thêm</span>
  </button>
</div>

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
  .input {
    display: flex;
    gap: 0.5rem;
  }

  // th,
  td {
    border-left: none;
    border-right: none;
    border-color: var(--bd-soft);
  }

  a {
    @include clamp();
    @include fgcolor(primary, 5);
    @include hover {
      @include fgcolor(primary, 6);
    }
  }

  input {
    width: 100%;
    padding-left: 0.5rem;
    padding-right: 0.5rem;

    border-color: var(--bd-soft);
  }

  .search {
    font-style: italic;
  }

  .warning {
    @include fgcolor(warning, 5);
    margin-top: 1rem;
  }

  table {
    margin-top: 0.5rem;
  }

  details {
    margin-top: 1rem;
  }

  summary {
    font-style: italic;
  }

  p,
  .form-label {
    margin-top: 0.75rem;
  }
</style>
