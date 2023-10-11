<script lang="ts">
  import { page } from '$app/stores'
  import { rel_time } from '$utils/time_utils'

  import type { PageData } from './$types'
  export let data: PageData

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  $: ({ props } = data)
  $: pager = new Pager($page.url, { pg: 1, tl: '' })

  const split_ulkey = (ulkey: string) => {
    const inputs = ulkey.split('/')

    const output: [string, string][] = []

    for (let i = 0; i < inputs.length; i++) {
      const full_path = inputs.slice(0, i + 1).join('/')
      output.push([full_path, inputs[i]])
    }
    return output
  }
</script>

<article class="article island">
  <h1>Lịch sử thu phí chương</h1>

  <table>
    <thead>
      <tr>
        <th>Người dùng</th>
        <th>Nguồn</th>
        <th>Vcoin</th>
        <th>Số chữ</th>
        <th>Hệ số</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each props.items as item}
        {@const vuser = props.users[item.vu_id]}
        <tr>
          <td class="user">
            <a
              class="cv-user"
              href={pager.gen_url({ by: item.vu_id, pg: 1 })}
              data-privi={vuser.privi}>
              <SIcon name="privi-{vuser.privi}" iset="icons" />
              <span class="-trim">{vuser.uname}</span>
            </a>
          </td>
          <td>
            <div class="ulkey">
              {#each split_ulkey(item.ulkey) as [href, text]}
                /<a
                  class="u-fg-secd u-fz-sm m-link"
                  href={pager.gen_url({ kw: href, pg: 1 })}>{text}</a>
              {/each}
            </div>
          </td>
          <td><span class="x-vcoin">{item.vcoin / 1000}</span> </td>
          <td>{item.zsize}</td>
          <td>{item.multp}</td>
          <td class="ctime">{rel_time(item.ctime)}</td>
        </tr>
      {/each}
    </tbody>
  </table>

  <footer>
    <Mpager {pager} pgidx={props.pgidx} pgmax={props.pgmax} />
  </footer>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);

    th,
    td {
      border-left: none;
      border-right: none;
      text-align: center;
    }
  }

  footer {
    margin-top: 0.75rem;
  }

  .cv-user {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;

    @include ftsize(sm);
  }

  .-trim {
    display: inline-block;
    @include clamp($width: null);
    // max-width: 100%;
  }

  .ulkey {
    @include flex-ca;
    line-height: 1.125rem;
  }

  .ctime {
    @include ftsize(sm);
    @include clamp($width: null);
    @include fgcolor(tert);
  }
</style>
