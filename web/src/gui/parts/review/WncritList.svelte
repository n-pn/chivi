<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from './YscritCard.svelte'
  import VicritCard from './VicritCard.svelte'

  export let vdata: CV.VicritList
  export let ydata: CV.YscritList

  export let wn_id = 0

  export let show_book = true
  export let show_list = true
</script>

{#each vdata.crits as crit}
  {@const book = vdata.books[crit.wn_id]}

  {#key crit.vc_id}
    <VicritCard {crit} {book} {show_book} {show_list} />
  {/key}
{:else}
  <div class="d-empty-sm">
    <p class="u-fg-tert fs-i">Chưa có đánh giá của người dùng.</p>

    {#if wn_id}
      <p>
        <a class="m-btn _primary _fill _lg" href="/br/+crit?wn=${wn_id}">
          <SIcon name="ballpen" />
          <span class="-text">Thêm đánh giá</span>
        </a>
      </p>
    {/if}
  </div>
{/each}

{#each ydata.crits as crit}
  {@const book = ydata.books[crit.book_id]}
  {@const user = ydata.users[crit.user_id]}
  {@const list = ydata.lists[crit.list_id]}

  {#key crit.id}
    <YscritCard {crit} {user} {book} {list} {show_book} {show_list} />
  {/key}
{:else}
  <div class="d-empty-sm">
    <p>Chưa có đánh giá từ Ưu Thư Võng</p>
  </div>
{/each}

<style lang="scss">
  header > a + a {
    margin-left: 0.5rem;
  }
</style>
