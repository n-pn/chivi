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
  <h1>Lịch sử mở khóa chương</h1>

  <table>
    <thead>
      <tr>
        <th>Nguồn</th>
        <th>Tiêu phí</th>
        <th class="show-ts">Chi tiết</th>
        <th>Người dùng</th>
        <th>Thời gian</th>
      </tr>
    </thead>

    <tbody>
      {#each props.items as item}
        {@const vuser = props.users[item.vu_id]}
        {@const owner = props.users[item.owner]}
        <tr>
          <td class="ulkey">
            {#each split_ulkey(item.ulkey) as [href, text]}
              /<a
                class="u-fg-secd u-fz-sm m-link"
                href={pager.gen_url({ kw: href, pg: 1 })}>{text}</a>
            {/each}
          </td>

          <td class="u-warn u-bold">{item.user_lost} ({item.owner_got})</td>
          <td class="u-fg-tert u-fz-sm show-ts"
            >{item.user_multp} ({item.real_multp}) [{item.zsize}]</td>

          <td class="user">
            <a
              class="cv-user"
              href={pager.gen_url({ by: item.vu_id, pg: 1 })}
              data-privi={vuser.privi}>
              <SIcon name="privi-{vuser.privi}" iset="icons" />
              <span class="-trim">{vuser.uname}</span>
            </a>
            <a
              class="cv-user"
              href={pager.gen_url({ to: item.owner, pg: 1 })}
              data-privi={owner.privi}>
              <SIcon name="privi-{owner.privi}" iset="icons" />
              <span class="-trim">{owner.uname}</span>
            </a>
          </td>

          <td class="u-fg-tert u-fz-sm">{rel_time(item.ctime)}</td>
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
      line-height: 1.25;
      padding: 0.5rem;
    }
  }

  table {
    margin-top: 1rem;
    @include bgcolor(secd);
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

  .ulkey {
    line-height: 1.125rem;
  }

  .show-ts {
    display: none;
    @include bp-min(ts) {
      display: table-cell;
    }
  }

  .-trim {
    display: inline-block;
    @include clamp($width: null);
    // max-width: 100%;
  }
</style>
