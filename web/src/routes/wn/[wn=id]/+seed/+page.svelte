<script lang="ts">
  import AddSeed from './AddSeed.svelte'

  export let data
  $: nvinfo = data.nvinfo

  const sources = [
    {
      site: 'uukanshu.com',
      href: 'https://www.uukanshu.com',
      desc: `Nguồn uukanshu có nhiều truyện, cập nhật nhanh,
nhưng text thường lỗi, có thể dùng tạm khi không có nguồn khác.`,
    },
    {
      site: '69shu.com',
      href: 'https://www.69shu.com',
      desc: 'Text nguồn này thường thiếu dấu câu, tốc độ đổi mới chậm, nhưng text khá sạch.',
    },
    {
      site: 'uuks.org',
      href: 'https://www.uuks.org',
      desc: 'Nguồn mới thêm, có text các trang hiếm như youdubook hay tadu.',
    },
    {
      site: '133txt.com',
      href: 'https://www.133txt.com',
      desc: 'Nguồn mới thêm, nhiều truyện, có cả truyện từ ciweimao.',
    },
    {
      site: 'biqugse.com',
      href: 'http://www.biqugse.com',
      desc: 'Nguồn mới thêm, chưa kiểm tra.',
    },
    {
      site: 'bqxs520.com',
      href: 'http://www.bqxs520.com',
      desc: 'Nguồn mới thêm, chứa nhiều rác.',
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
      site: 'yannuozw.com',
      href: 'http://www.yannuozw.com',
      desc: 'Nguồn mới thêm, có text faloo.',
    },
    {
      site: 'kanshu8.net',
      href: 'http://www.kanshu8.net',
      desc: 'Nguồn mới thêm, chưa kiểm tra.',
    },
    {
      site: 'rengshu.com',
      href: 'http://www.rengshu.com',
      desc: `Nguồn text sạch, nhưng ít truyện.`,
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
    {
      site: 'shubaow.net',
      href: 'http://www.shubaow.net',
      desc: 'Nguồn này chứa nhiều truyện độc, nhưng ban IP nước ngoài/server, hiện tại chỉ truy cập được từ TQ hoặc Hàn Quốc.',
    },
  ]

  $: google_url = 'https://www.google.com/search?q=' + nvinfo.ztitle
</script>

<article class="article island md-article">
  <h3>Quản lý nguồn truyện cho bộ [{nvinfo.vtitle}]</h3>

  <AddSeed {nvinfo} />

  <details open>
    <summary>Các nguồn đang được hỗ trợ</summary>

    <table>
      <thead>
        <tr>
          <th>Đường dẫn</th>
          <th class="search">Tìm nhanh</th>
          <th>Chú thích</th>
        </tr>
      </thead>
      <tbody>
        {#each sources as { site, href, desc }}
          <tr>
            <td class="href"
              ><a {href} rel="noreferrer" target="_blank">{href}</a></td>
            <td class="search">
              <a
                href="{google_url} site:{site}"
                rel="noreferrer"
                target="_blank">Google</a>
              <!-- {#if custom_search}
                  <a
                    href={custom_search}
                    rel="noreferrer"
                    target="_blank">{site}</a>
                {/if} -->
            </td>

            <td class="desc">{desc}</td>
          </tr>
          <div class="source">
            <div class="name" />
            <div class="search" />
          </div>
        {/each}
      </tbody>
    </table>
  </details>

  <p class="protip">
    Muốn thêm nguồn mới, hãy liên hệ ban quản trị thông qua kênh <a
      href="https://discord.gg/mdC3KQH">Discord</a> của trang.
  </p>

  <h3>Chú thích thêm</h3>

  <p class="extra">
    Một số nguồn khác như <code>bxwxorg.com</code>, <code>biqugee.com</code>,
    <code>zhwenpg.com</code> hiện tại đã ngừng hoạt động.
  </p>
  <p class="extra">
    Các nguồn <code>jx.la</code>, <code>sdyfcm.com</code> tuy còn sống nhưng đã đổi
    format khá khó chịu, cho nên cũng không được hỗ trợ.
  </p>
</article>

<style lang="scss">
  article {
    @include margin-y(var(--gutter));

    padding-bottom: 1rem;

    > :global(* + *) {
      margin-top: 1rem;
    }
  }

  summary {
    @include ftsize(lg);
    margin-bottom: 0.75rem;
  }

  .source {
    display: flex;
    max-width: 30rem;
  }

  .search {
    text-align: center;
    a {
      display: block;
    }
  }

  .desc {
    @include ftsize(xs);
    @include fgcolor(tert);
    max-width: 14rem;
    line-height: 1rem;
    padding: 0.25rem 0.5rem;
  }

  a {
    @include fgcolor(primary, 5);
  }

  .protip {
    // margin: 1.5rem 0;
    // line-height: 1rem;
    font-style: italic;
    @include fgcolor(warning, 5);
  }

  .extra {
    @include ftsize(sm);
    line-height: 1rem;
    @include fgcolor(tert);
  }
</style>
